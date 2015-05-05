-module(updatephone_handler).
-export([init/3]).

-export([welcome/2, terminate/3, allowed_methods/2]).
-export([content_types_accepted/2]).
-import(rendering_methods,[error_response/2, responseBody/2, decoding_request/1, user_id_from_name/1, get_value_from_render/2]). 

init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.
allowed_methods(Req, State) ->  
    {[<<"POST">>], Req, State}.  
content_types_accepted(Req, State) ->
{[{<<"application/json">>, welcome}], Req, State}.
terminate(_Reason, _Req, _State) ->
	ok.
welcome(Req, State) ->



{Req_Body_decoded, Req2} = decoding_request(Req),
{ok, ReqBody, Req2} = cowboy_req:body_qs(Req),
[{ReqBodyExtracted, true}] = ReqBody,lager:log(info, []," Req_Body_decoded result is ~p ~n", [Req_Body_decoded]),
Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"phone\": {\"type\": \"string\", \"required\":true}}}">>,
Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),io:format("~n it's just a gap2**************************************** start ~n"),
Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
Result_Body = case  Jess_validation of
	{ok, _} -> 
		UserName = get_value_from_render(<<"userName">>, Req_Body_decoded),		lager:log(info, []," UserName is ~p ~n", [UserName]),
		Phone = get_value_from_render(<<"phone">>, Req_Body_decoded),		lager:log(info, []," Phone is ~p ~n", [Phone]),

		
	    

	    Phone_length = re:run(Phone, "[0-9]{10,11}"),		lager:log(info,[], "phone match result is  ~p ~n", [Phone_length]),
		Phone_lenght_result = case Phone_length == nomatch of			
			true -> 
				jsx:encode([{<<"status">>, 1},{<<"message">>, <<"Phone number not in format">>}]);
			false -> 
				Checking_availability = "select * from lycusers where username = '"++ binary_to_list(UserName) ++"' and phone = '"++ binary_to_list(Phone) ++"'",		lager:log(info, []," Checking_availability is  ~p ~n", [Checking_availability]),
			 	{result_packet,_,_,Check_Result,_} = emysql:execute(lycos_pool, Checking_availability),	    lager:log(info, []," Check_Result result is ~p ~n", [Check_Result]),
			    LengthOfResult = length(Check_Result), 		lager:log(info, []," LengthOfResult is ~p ~n", [LengthOfResult]),
			    ResultBody = case LengthOfResult =:= 0 of
			        true ->
		    			Building_Query = "UPDATE lycusers SET PHONE = '"++ binary_to_list(Phone) ++"' WHERE USERNAME = '"++ binary_to_list(UserName) ++"'",				lager:log(info, []," Building_Query   ~p ~n", [Building_Query]),
						Result = emysql:execute(lycos_pool, Building_Query),			    lager:log(info, []," Result result is ~p ~n", [Result]),

						AffectedRows = emysql:affected_rows(Result),				lager:log(info, []," AffectedRows result is ~p ~n", [AffectedRows]),
						
						case AffectedRows>0 of
					        true -> <<"{\"status\": 0,\"message\": \"Phone number is updated\"}">>;
					        false -> <<"{\"status\": 1,\"message\": \"Nothing to update\"}">>			        
					    end;
			            
			        false ->
			        	
		               jsx:encode([{<<"status">>, 1},{<<"message">>, <<"Nothing to update">>}])	        	
		    	end,

			ResultBody

		end,
		lager:log(info,[], "Phone_lenght_result is ~p ~n", [Phone_lenght_result]),





		Phone_lenght_result;

	{error, _} ->
		jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
end,

	lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
	lager:log(info, []," Result_Body  is ~p ~n", [Result_Body]),
 	
	Res1 = cowboy_req:set_resp_body(Result_Body, Req2),
	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
	Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
	{true, Res3, State}.

