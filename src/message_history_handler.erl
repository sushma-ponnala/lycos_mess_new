-module(message_history_handler).
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
			Schema = <<"{\"properties\": {\"sender\": {\"type\": \"string\", \"required\":true}}}">>,
			Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
			% %lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
			io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
			io:format("~n it's just a gap2**************************************** start ~n"),
			Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
			%lager:log(info, []," Jess_validation  error ~p ~n", [Jess_validation]),
			Result_Body = case  Jess_validation of
				{ok, _} -> 



				UserName = get_value_from_render(<<"sender">>, Req_Body_decoded),
				lager:log(info, []," UserName  is ~p ~n", [UserName]),
				Building_Query_For_Id = "SELECT ID FROM lycusers WHERE USERNAME = '"++ binary_to_list(UserName)++"' ", 
				lager:log(info, []," Building_Query_For_Id  is ~p ~n", [Building_Query_For_Id]),
				Sender_id = emysql:execute(lycos_pool, Building_Query_For_Id), 
				lager:log(info, []," Sender_id  is ~p ~n", [Sender_id]),
				
    			[[{<<"ID">>,Sender_Id}]] = emysql:as_proplist(Sender_id),
    			lager:log(info, []," Sender_Id  is ~p ~n", [Sender_Id]),


    			Buidling_Query_For_Message = "select rec.receiver_id, lu.username as sender, rec.username as receiver, rec.sender_id, rec.msgType,rec.localPathSender,rec.localPathReceiver,rec.remotePath,rec.mapLat,rec.mapLong,rec.msgDate,rec.msgTime,rec.msgTz,rec.msgStatus,lu.username from (select lycmessages.id, receiver_id, lycusers.username, sender_id,lycmessages.msg_type as msgType,lycmessages.local_path_sender as localPathSender,lycmessages.local_path_receiver as localPathReceiver,lycmessages.remote_path as remotePath,lycmessages.map_lat as mapLat,lycmessages.map_long as mapLong,lycmessages.msg_date as msgDate,date_format(lycmessages.MSG_TIME, '%H-%i-%s') as msgTime,lycmessages.msg_tz as msgTz,lycmessages.msg_status as msgStatus from lycmessages JOIN lycusers ON lycusers.id = lycmessages.receiver_id where lycmessages.sender_id = "++integer_to_list(Sender_Id)++") as rec JOIN lycusers lu where rec.sender_id = lu.id;",
    			lager:log(info, []," Buidling_Query_For_Message  is ~p ~n", [Buidling_Query_For_Message]),
    			Result  = emysql:execute(lycos_pool, Buidling_Query_For_Message),
			    Message_JSON = emysql:as_json(Result),				     lager:log(info, [],"~n Result result is ~p ~n", [Message_JSON]),


			    Building_Query1 = "SELECT DISTINCT GROUPNAME FROM lycbuddygroups WHERE ID IN (SELECT DISTINCT GROUP_ID FROM lycusers_buddygroups WHERE USER_NAME = '"++binary_to_list(UserName)++"') ",
				lager:log(info, []," Building_Query1  ~p ~n", [Building_Query1]),
				UserGroups = emysql:execute(lycos_pool, Building_Query1),
				lager:log(info, []," UserGroups ----------------- is ~p ~n", [UserGroups]),
				{result_packet,_,_,UserGroups_Json_Result,_} = UserGroups,
				
				% UserGroups_Json = emysql:as_json(UserGroups),



				GroupContacts = emysql:execute(lycos_pool,"SELECT DISTINCT user_name FROM lycusers_buddygroups WHERE GROUP_ID IN (SELECT DISTINCT GROUP_ID FROM lycusers_buddygroups WHERE USER_NAME = '"++binary_to_list(UserName)++"')"),
				lager:log(info, []," GroupContacts ------------------ is ~p ~n", [GroupContacts]),
				{result_packet,_,_,Group_contact_Result,_} = GroupContacts,
				% GroupContacts_Json = emysql:as_json(GroupContacts),



				Building_Query_UserData = "SELECT username, namespace, loginalias, firstname, lastname, address, city, zip, state, country, email, phone, isd, telegram, gender, birthday as dob FROM lycusers WHERE USERNAME  = '"++ binary_to_list(UserName) ++"'",				lager:log(info, []," Building_Query_UserData  ~p ~n", [Building_Query_UserData]),
				SqlResult = emysql:execute(lycos_pool, Building_Query_UserData), 				lager:log(info, []," Result from Sql database is ~p ~n", [SqlResult]),
				User_Data_JSON = emysql:as_json(SqlResult),lager:log(info, []," JSON  error ~p ~n", [User_Data_JSON]),

			    FinalyResult = jsx:encode([
			    	{<<"status">>, 0},
			    	{<<"telegram">>,<<"true">>},
			    	{<<"userData">>,User_Data_JSON},
			    	{<<"telegram">>,<<"true">>},
			    	{<<"message">>,Message_JSON},
			    	{<<"groupContacts">>, lists:append(Group_contact_Result)},
			    	{<<"userGroups">>,lists:append(UserGroups_Json_Result)}
			    	]),
			    FinalyResult;

				{error, _} ->
				jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
			end,



			lager:log(info, []," Result_Body  is ~p ~n", [Result_Body]),
			lager:log(info, []," Req_Body_decoded  is ~p ~n", [Req_Body_decoded]),


			Res1 = cowboy_req:set_resp_body(Result_Body, Req2),
			Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
			Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
			{true, Res3, State}.
































% % io:format("Initial Req from the request  is ~p ~n", [Req]),
% % io:format("Initial State from the request is ~p ~n", [State]),
% 	% Req_method = cowboy_req:method(Req),
% 	% io:format("Req_method is ~p ~n", [Req_method]),
% 	 {ok, <<Req_Body>>, {}} = cowboy_req:body(Req),

% 	io:format("Body is ~p ~n", [Req_Body]),
% 	Body = <<"<h1>This is a response for other methods</h1>">>,
% 	% io:format("Body is  ~p ~n",[Body]),
% 	{Body, Req, State}.
%      % Req1 = cowboy_http_req:body(Req),
% 	% io:format("Request is ~p ~n", [Req1]),
% 	% io:format("password ~p ~n",[Req]),
% 	% compile:file("/home/waheguru/erlang-projects/contentapi/src/mysql.erl"),
% 	% compile:file("/home/waheguru/erlang-projects/contentapi/src/mysql_conn.erl"),
% 	% mysql:start_link(p1, "localhost", "root", "password", "tracker"),
% 	% io:format("Request is ~p ~n",[p1]),
% 	% Result1 = mysql:fetch(p1, <<"SELECT * FROM maxcdnlogs limit 1">>),
% 	% io:format("Result1: ~p~n", [Result1]),
% 	 % mysql:start_link("localhost", "root", "password", "tracker"),
% 	% io:format("Request is ~p ~n",[Req]),


% 	% {Username, _} = cowboy_req:qs_val(<<"username">>, Req),
% 	% io:format("Username is  ~p ~n",[Username]),
% 	% {Password, _} = cowboy_req:qs_val(<<"password">>, Req),
% 	% io:format("Password is  ~p ~n",[Password]),
% 	% {Namespace, _} = cowboy_req:qs_val(<<"namespace">>, Req),
% 	% io:format("Namespace is  ~p ~n",[Namespace]),


% 	%%mysql query to execute
% 	% mysql:start_link(connection, 3306 , root, abc123, lycos),

% 	% io:format("password ~p ~n",[Password]),

% 	% {Username, _} =  cowboy_req:qs_val(<<"Username">>, Req),
% 	% {Password, _} =  cowboy_req:qs_val(<<"Password">>, Req),
% 	% {Namespace, _} = cowboy_req:qs_val(<<"Namespace">>, Req),

% 	% Body = "{ 'username':'"++binary_to_list(Username)++"'},{ 'password':'"++binary_to_list(Password)++"'},{ 'namespace':'"++binary_to_list(Namespace)++"'}",
% 	% io:format("Body is  ~p ~n",[Body]),
%     % {Body, Req, State}.