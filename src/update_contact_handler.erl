-module(update_contact_handler).
	-export([init/3, welcome/2, terminate/3, allowed_methods/2, content_types_accepted/2]).
	-import(rendering_methods,[error_response/2, responseBody/2, decoding_request/1, user_id_from_name/1, get_value_from_render/2]). 
	-include("config.hrl").

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
	[{ReqBodyExtracted, true}] = ReqBody,
 	%lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),

 	Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"userStatus\": {\"type\": \"string\", \"required\":true}, \"contactName\": {\"type\": \"string\", \"required\":true}, \"contactStatus\": {\"type\": \"string\", \"required\":true}}}">>,
 	% io:format("~n it's just a gap1 ~n"),
 	Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
 	% %lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
 	io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
 	io:format("~n it's just a gap2**************************************** start ~n"),
 	Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
	%lager:log(info, []," Jess_validation  error ~p ~n", [Jess_validation]),
 	Result_Body = case  Jess_validation of
		{ok, _} -> 
			UserStatus = get_value_from_render(<<"userStatus">>, Req_Body_decoded), 
			UserName = get_value_from_render(<<"userName">>, Req_Body_decoded), 
			ContactName = get_value_from_render(<<"contactName">>, Req_Body_decoded), 
		 	ContactStatus = get_value_from_render(<<"contactStatus">>, Req_Body_decoded), 


		 	User_Id = user_id_from_name(UserName), %lager:log(info, []," User_Id is ~p ~n", [User_Id]),
		 	Contact_Id = user_id_from_name(ContactName), %lager:log(info, []," Contact_Id is ~p ~n", [Contact_Id]),

		 	% Query_Result = emysql:execute(lycos_pool, "SELECT ID FROM usercontacts WHERE USER_ID = '"++integer_to_list(User_Id)++"' AND CONTACT_ID = '"++integer_to_list(Contact_Id)++"' "),
		 	%lager:log(info, []," Query_Result is ~p ~n", [Query_Result]),
			{result_packet,_,_,IdContent,_} =  emysql:execute(lycos_pool, "SELECT ID FROM usercontacts WHERE USER_ID = '"++integer_to_list(User_Id)++"' AND CONTACT_ID = '"++integer_to_list(Contact_Id)++"' "),
		    %lager:log(info, []," IdContent is ~p ~n", [IdContent]),
			Body = case length(IdContent) =/= 0  of
			    false ->
			        <<"{\"status\": \"1\",
			            \"message\": \"UserName or ContactName doesn't exist\"}">>;
			    
			    true ->
			    %lager:log(info, []," UserStatus is ~p ~n", [UserStatus]),
			    BuildingQuery = "UPDATE usercontacts SET USER_ID = " ++ integer_to_list(User_Id) ++", SELF_STATUS = '"++  binary_to_list(UserStatus) ++"', CONTACT_ID = "++ integer_to_list(Contact_Id) ++", CONTACT_STATUS = '"++ binary_to_list(ContactStatus) ++"' ",
			    %  

			    %lager:log(info, []," BuildingQuery is ~p ~n", [BuildingQuery]),
			    %lager:log(info, []," I am into Body iteration ~p ~n", [IdContent]),

			        Result = emysql:execute(lycos_pool, BuildingQuery),
			        %lager:log(info, []," Result is ~p ~n", [Result]),
			        AffectedRows = emysql:affected_rows(Result),
			        case AffectedRows>0 of
			            true ->
			                <<"{\"status\": \"0\",
			                    \"message\": \"Updated Successfuly\"}">>;
			            false ->
			                <<"{\"status\": \"1\",
			                    \"message\": \"Nothing to update\"}">>
			        end
			end,
			 %lager:log(info, []," Body is ~p ~n", [Body]),
			Body;
		{error, _} ->
			jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
		end,

		Res1 = cowboy_req:set_resp_body(Result_Body, Req2),
		Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
		Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
		{true, Res3, State}

		.



	% process_response("PRESET", Body, Req, State, StatusCode)->
	% 		Req2 = cowboy_req:set_resp_header(<<"StatusCode">>, StatusCode, Req),
	% 		Req3 = cowboy_req:set_resp_body(Body, Req2),
	% 		{true, Req3, State}.













	% {ok, ReqBody, Req2} = cowboy_req:body_qs(Req),
 % 	[{ReqBodyExtracted, true}] = ReqBody,
 % 	%lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),

 % 	Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"userStatus\": {\"type\": \"string\", \"required\":true}, \"contactName\": {\"type\": \"string\", \"required\":true}, \"contactStatus\": {\"type\": \"string\", \"required\":true}}}">>,
 % 	% io:format("~n it's just a gap1 ~n"),
 % 	Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
 % 	% %lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
 % 	io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
 % 	io:format("~n it's just a gap2**************************************** start ~n"),

 % 	Jesse_result = case jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]) of
	% 	{ok, _} -> 
	% 		"valid data ";
	% 	{error, _} ->
	% 		error_response(Req2, State)
	% 	end
	% ,
 % 	io:format("~n Jesse_result is ~p ~n", [Jesse_result]),

 % 	io:format("~n it's just a gap2**************************************** end ~n"),

 % 	Req_Body_decoded= jsx:decode(ReqBodyExtracted),
