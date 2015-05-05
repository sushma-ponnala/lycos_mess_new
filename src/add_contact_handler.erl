-module(add_contact_handler).
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
	[{ReqBodyExtracted, true}] = ReqBody,
	Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"contacts\": {\"type\": \"array\", \"required\":true}}}">>,
	Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
	io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
	io:format("~n it's just a gap2**************************************** start ~n"),
	Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),





	Result_Body = case  Jess_validation of
		{ok, _} -> 
			UserName 	 = get_value_from_render(<<"userName">>, Req_Body_decoded),
			Contacts        = get_value_from_render(<<"contacts">>, Req_Body_decoded),
			User_Id = user_id_from_name(UserName), lager:log(info, []," User_Id is ~p ~n", [User_Id]),

			

			Body123 = lists:foreach( fun(X)-> 
				lager:log(info, []," X is ~p ~n", [X]),
				ContactName = binary_to_list(X),
				
				Building_Query = "SELECT ID FROM lycusers WHERE USERNAME = '"++ContactName++"' ",
				
				Contact_id = emysql:execute(lycos_pool, Building_Query),
				

				[[{<<"ID">>,Contact_Id}]] = emysql:as_proplist(Contact_id),


				{result_packet,_,_,IdContent,_} =  emysql:execute(lycos_pool, "SELECT ID FROM usercontacts WHERE USER_ID = '"++integer_to_list(User_Id)++"' AND CONTACT_ID = '"++integer_to_list(Contact_Id)++"' "),
				lager:log(info, []," IdContentssssss is ~p ~n", [IdContent]),
				LengthOfResult = length(IdContent),
				lager:log(info, []," LengthOfResult is ~p ~n", [LengthOfResult]),
			  

			    Body = case LengthOfResult =/= 0 of
			        true ->
			        	Result = jsx:encode([{<<"status">>, 1},{<<"message">>, <<"contact already exist">>}]),
			        	Result;
			            
			        false ->
			        	Building_Query_inner = "INSERT INTO usercontacts (USER_ID, CONTACT_ID) values ('"++integer_to_list(User_Id)++"','"++integer_to_list(Contact_Id)++"')",
			        	lager:log(info, []," Building_Query_inner is ~p ~n", [Building_Query_inner]),
			            Result1 = emysql:execute(lycos_pool, Building_Query_inner),
			            lager:log(info, []," Result is ~p ~n", [Result1]),
			            Id = emysql:insert_id(Result1),
		                Result = case Id>0 of
		                    true ->
		                    jsx:encode([{<<"status">>, 0},{<<"message">>, <<"contacts added">>}]);
		                    false ->
		                    jsx:encode([{<<"message">>, <<"something wrong">>}])
		                end,
		                 lager:log(info, []," Result is ~p ~n", [Result]),
		                Result
			    	end
			    ,
			    lager:log(info, []," Bodyinner is ~p ~n", [Body]), 
			    Body
			end,Contacts),
			lager:log(info, []," Bodyouter is ~p ~n", [Body123]),



			Checking_Body = case Body123 =:= ok of
				true -> 
		 			lager:log(info, []," Body1234567899 is ~p ~n", [Body123]),
					lager:log(info, []," Contacts is ~p ~n", [Contacts]),
					jsx:encode([{<<"status">>, 0},{<<"message">>, <<"contacts added">>}]);
				false -> 
				 jsx:encode([{<<"message">>, <<"something wrong">>}])
				end, 
				Checking_Body;
		{error, _} ->
			jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
	end,
	lager:log(info, []," Req_Body_decoded result is ~p ~n", [Req_Body_decoded]),	lager:log(info, []," Result_Body result is ~p ~n", [Result_Body]),




	% io:format("from add_contact_handler"),
 	% {ok, ReqBody, Req2} = cowboy_req:body(Req), 	
	Res1 = cowboy_req:set_resp_body(Result_Body, Req2),
	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
	Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
	{true, Res3, State}.
