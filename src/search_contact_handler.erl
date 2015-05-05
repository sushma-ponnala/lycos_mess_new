-module(search_contact_handler).
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
	[{ReqBodyExtracted, true}] = ReqBody,lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),

	Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"searchStr\": {\"type\": \"string\", \"required\":true}}}">>,
	Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]), io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]), io:format("~n it's just a gap2**************************************** start ~n"), 
	Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),

	Result_Body = case  Jess_validation of
		{ok, _} -> 
			UserName  = get_value_from_render(<<"userName">>, Req_Body_decoded), lager:log(info, []," UserName  is ~p ~n", [UserName]),
			SearchStr = get_value_from_render(<<"searchStr">>, Req_Body_decoded), 			lager:log(info, []," SearchStr is ~p ~n", [SearchStr]),

			User_id = user_id_from_name(UserName), 			lager:log(info, []," User_id  ~p ~n", [User_id]),
			Building_Query = "select rec.contactname, rec.firstname, rec.lastname, rec.id, self_status, contact_status from  (select id, username as contactname, firstname, lastname FROM lycusers where username like '"++ binary_to_list(SearchStr) ++"%') as rec join usercontacts ",%where user_id = "++integer_to_list(User_id)++" and contact_id = rec.id ", 			lager:log(info, []," Building_Query   ~p ~n", [Building_Query]),
			Result = emysql:execute(lycos_pool, Building_Query),
		    JSON = emysql:as_json(Result), 		    lager:log(info, []," Result result is ~p ~n", [Result]),
		  
		    UserGroups_Json = case length(JSON) =/= 0 of
				true -> 
				    Building_Query1 = "SELECT DISTINCT GROUPNAME FROM lycbuddygroups WHERE ID IN (SELECT DISTINCT GROUP_ID FROM lycusers_buddygroups WHERE USER_NAME = '"++binary_to_list(UserName)++"') ", 					lager:log(info, []," Building_Query1  ~p ~n", [Building_Query1]),
					emysql:execute(lycos_pool, Building_Query1);
					% emysql:as_json(UserGroups);

					
				false -> 
					Result = jsx:encode([]),
					Result
			end,
			GroupContacts_Json = case length(JSON) =/= 0 of

				true -> 

					GroupContacts = emysql:execute(lycos_pool,"SELECT DISTINCT user_name FROM lycusers_buddygroups WHERE GROUP_ID IN (SELECT DISTINCT GROUP_ID FROM lycusers_buddygroups WHERE USER_NAME = '"++binary_to_list(UserName)++"')"),
					 GroupContacts;
					 % emysql:as_json(GroupContacts);

					
				false -> 
					 jsx:encode([])
					
			end,
			{result_packet,_,_,UserGroups_Json_Result,_} = UserGroups_Json,
			{result_packet,_,_,Group_contact_Result,_} = GroupContacts_Json,
		    % jsx:encode([{<<"error">>, <<"UnRecognized web service">>}]),
		    Body4 = jsx:encode([
		    	{<<"status">>, 0},
		    	{<<"message">>,JSON},
		    	{<<"telegram">>,<<"true">>},
		    	{<<"userData">>,<<"true">>},
		    	{<<"groupContacts">>, lists:append(Group_contact_Result)},
		    	{<<"userGroups">>, lists:append(UserGroups_Json_Result)}
		    	]),
		    lager:log(info, []," Body4  is ~p ~n", [Body4]),
		    Body4;
		{error, _} ->
			jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
	end,

	lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
	lager:log(info, []," Result_Body  is ~p ~n", [Result_Body]),
 	
	Res1 = cowboy_req:set_resp_body(Result_Body, Req2),
	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
	Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
	{true, Res3, State}.