-module(login_handler).
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
lager:log(info, [], "Req is", [Req]),

	io:format("from login_handler"),
	{Req_Body_decoded, Req2} = decoding_request(Req),
	lager:log(info, []," Req_Body_decoded  is ~p ~n", [Req_Body_decoded]),

 	{ok, ReqBody, Req2} = cowboy_req:body_qs(Req),
	[{ReqBodyExtracted, true}] = ReqBody,		lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),

	Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"pass\": {\"type\": \"string\", \"required\":true}, \"namespace\": {\"type\": \"string\", \"required\":true}}}">>,
	Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
	Result_Body = case  Jess_validation of
		{ok, _} -> 
			UserName  = get_value_from_render(<<"userName">>, Req_Body_decoded), lager:log(info, []," UserName  is ~p ~n", [UserName]),
			Pass 	  = get_value_from_render(<<"pass">>, Req_Body_decoded), lager:log(info, []," Pass  is ~p ~n", [Pass]),
			Namespace = get_value_from_render(<<"namespace">>, Req_Body_decoded), lager:log(info, []," Namespace  is ~p ~n", [Namespace]),

			Check_availability_Query1 = "select uname, password from (select mongooseim.users.username as uname, mongooseim.users.password from mongooseim.users union all select lycosapp.lycusers.username as uname, lycosapp.lycusers.pass as password from lycosapp.lycusers) as rec where uname ='"++ binary_to_list(UserName) ++ "' and password = '"++binary_to_list(Pass)++"'",				lager:log(info, []," Check_availability_Query1   ~p ~n", [Check_availability_Query1]),
			{result_packet,_,_,CheckUser,_} = emysql:execute(lycos_pool, Check_availability_Query1),lager:log(info, []," CheckUser result is ~p ~n", [CheckUser]),
			LengthOfResult = length(CheckUser),	lager:log(info, []," LengthOfResult result is ~p ~n", [LengthOfResult]),
			ResultBody = case LengthOfResult =/= 0 of
		        true -> 
					Building_Query = "SELECT username, namespace, loginalias, firstname, lastname, address, city, zip, state, country, email, phone, isd, telegram, gender, birthday as dob FROM lycusers WHERE USERNAME  = '"++ binary_to_list(UserName) ++"' AND PASS = '"++binary_to_list(Pass)++"' AND NAMESPACE = '"++binary_to_list(Namespace)++"'",			lager:log(info, []," Building_Query check here  ~p ~n", [Building_Query]),
					SqlResult = emysql:execute(lycos_pool, Building_Query),			lager:log(info, []," Result from Sql database is ~p ~n", [SqlResult]),
				    JSON = emysql:as_json(SqlResult),lager:log(info, []," JSON   ~p ~n", [JSON]),
				    LengthOfJson = length(JSON), 		    lager:log(info, []," LengthOfJson is ~p ~n", [LengthOfJson]),
				    UserGroups_Json = case length(JSON) =/= 0 of
						true -> 
						    Building_Query1 = "SELECT DISTINCT GROUPNAME FROM lycbuddygroups WHERE ID IN (SELECT DISTINCT GROUP_ID FROM lycusers_buddygroups WHERE USER_NAME = '"++binary_to_list(UserName)++"') ",					lager:log(info, []," Building_Query1  ~p ~n", [Building_Query1]),
							emysql:execute(lycos_pool, Building_Query1);
							
						false -> 
							 jsx:encode([])
					end,
					GroupContacts_Json = case length(JSON) =/= 0 of
						true -> 
							Building_Query2 = "SELECT DISTINCT user_name FROM lycusers_buddygroups WHERE GROUP_ID IN (SELECT DISTINCT GROUP_ID FROM lycusers_buddygroups WHERE USER_NAME = '"++binary_to_list(UserName)++"')",
							lager:log(info, []," Building_Query2  ~p ~n", [Building_Query2]),
							 emysql:execute(lycos_pool, Building_Query2);
						false -> 
							 jsx:encode([])
					end,
					{result_packet,_,_,UserGroups_Json_Result,_} = UserGroups_Json,
					{result_packet,_,_,Group_contact_Result,_} = GroupContacts_Json,

				    Body4 = jsx:encode([{<<"status">>, 0},{<<"message">>,<<"null">>},{<<"telegram">>,<<"true">>},{<<"userData">>,JSON},{<<"groupContacts">>, lists:append(Group_contact_Result)},{<<"userGroups">>, lists:append(UserGroups_Json_Result)}]),		    lager:log(info, []," Body4  is ~p ~n", [Body4]),
				    Body4;
		            
		        false ->		        	
		           jsx:encode([{<<"message">>, <<"Wrong Username or Password">>}])	        	
			end,
			lager:log(info, []," ResultBody is ----------------------- ~p ~n", [ResultBody]),
			ResultBody;			
		{error, _} ->
			jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
		end
	,

 	
	Res1 = cowboy_req:set_resp_body(Result_Body, Req2),
	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
	Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
	{true, Res3, State}. 