-module(checkphone_handler).
	-export([init/3, welcome/2, terminate/3, allowed_methods/2, content_types_accepted/2, check_length/1, check_phone/3]).
	-import(rendering_methods,[responseBody/3, decoding_request/1, get_value_from_render/2]). 
	-include("config.hrl").

	init(_Transport, _Req, []) ->
		{upgrade, protocol, cowboy_rest}.

	allowed_methods(Req, State) ->  
	    {[<<"POST">>], Req, State}.  

	content_types_accepted(Req, State) ->
	{[{<<"application/json">>, welcome}], Req, State}.

	terminate(_Reason, _Req, _State) ->
		ok.

% Start of main function

welcome(Req, State) ->
	{Req_Body_decoded, Req2} = decoding_request(Req),
	{ok, ReqBody, Req2} = cowboy_req:body_qs(Req),
	[{ReqBodyExtracted, true}] = ReqBody,
	lager:log(info, []," Req_Body_decoded result is ~p ~n", [Req_Body_decoded]),

	%lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),
	Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"phone\": {\"type\": \"string\", \"required\":true}}}">>,

	% io:format("~n it's just a gap1 ~n"),
	Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
	% %lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
	io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
	io:format("~n it's just a gap2**************************************** start ~n"),
	Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
	%lager:log(info, []," Jess_validation  error ~p ~n", [Jess_validation]),
	Res1Body = case  Jess_validation of
		{ok, _} -> 


			Res2Body =  check_phone(Req_Body_decoded, Req2, State),
			Res2Body;
			
		{error, _} ->
			jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
	end,

		lager:log(info,[], "ResBody1234 is ~p ~n", [Res1Body]),
		Res1 = cowboy_req:set_resp_body(Res1Body, Req2),
		Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
		Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
		{true, Res3, State}.

check_phone(Req_Body_decoded, Req2, State) -> 
	Final_result = case proplists:is_defined(?Phone_no,Req_Body_decoded) of
		true ->
			%% Also check the validity of a phone
			Phone = get_value_from_render(?Phone_no, Req_Body_decoded),	
			lager:log(info,[], "Phone number is ~p ~n", [Phone]),
			Phone_length = re:run(Phone, "[0-9]{10}"),
			lager:log(info,[], "Phone_length is ~p ~n", [Phone_length]),
			Phone_lenght_result = case Phone_length == nomatch of
				
				true -> 
				% error_response(Req2, State)
				 jsx:encode([{<<"error">>, <<"UnRecognized web service">>}]);
				% responseBody(Error_res, Req2, State);
				false -> 
					lager:log(info,[], "into false condition match ~n"),
					Res2Body = check_length(Phone),
					lager:log(info,[], "Res2Body is ~p ~n", [Req2]),
					lager:log(info,[], "Res2Body is ~p ~n", [State]),
					 % responseBody(Res2Body, Req2, State)
					 Res2Body
			end,
			lager:log(info,[], "Phone_lenght_result is ~p ~n", [Phone_lenght_result]),
			Phone_lenght_result
			;
		false ->
			jsx:encode([{?Res_Error, <<"UnRecognized web service">>},{status, 401}])
	end,
	lager:log(info,[], "Final_result is ~p ~n", [Final_result]),
	Final_result
.	
  


check_length(Phone) ->
	case size(Phone) =:= 10 of 
		true -> 
			lager:log(info,[], "into check_length true ~n"),
		 	Phone1 = binary_to_list(Phone), 		lager:log(info,[], "Phone number is ~p ~n", [Phone1]),		 	
		 	emysql:prepare(my_st, << "select * from lycusers where phone = ?">>),
		 	Result = emysql:execute(lycos_pool, my_st, [Phone1]),
			Result_list = emysql:as_proplist(Result), lager:log(info,[], "Result_list ~p ~n", [Result_list]),
			case length(Result_list) =/= 0 of
				true -> 
				lager:log(info, []," true ~n"),
				jsx:encode([{?Res_Query,0}, {?Res_Article,<<"Phone number already taken">>}]);
				false -> 
				lager:log(info, []," false  ~n"),
				jsx:encode([{?Res_Query,1}, {?Res_Article,<<"Phone number not taken">>}])
			end;
		false -> 
			Res_Body = jsx:encode([{?Res_Error, <<"size of Phone is not equal to 10">>},{status, 401}]),
			% lager:log(info,[], "size of Phone is not equal to 10  ~p ~n"),
			Res_Body
	end
.

