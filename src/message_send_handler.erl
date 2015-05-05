-module(message_send_handler).
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
		%lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),
		% Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"userStatus\": {\"type\": \"string\", \"required\":true}, \"contactName\": {\"type\": \"string\", \"required\":true}, \"contactStatus\": {\"type\": \"string\", \"required\":true}}}">>,
		 Schema = <<"{\"properties\": { \"sender\": {\"type\": \"string\", \"required\":true}, \"receiver\": {\"type\": \"string\", \"required\":true},  \"msgType\": {\"type\": \"string\", \"required\":true},  \"msg\": {\"type\": \"string\", \"required\":true},  \"localPathSender\": {\"type\": \"string\", \"required\":true},  \"localPathReceiver\": {\"type\": \"string\", \"required\":true},  \"msgDate\": {\"type\": \"string\", \"required\":true},  \"msgTime\": {\"type\": \"string\", \"required\":true},  \"msgTz\": {\"type\": \"string\", \"required\":true}, \"msgStatus\": {\"type\": \"string\", \"required\":true} }}">>,

		% io:format("~n it's just a gap1 ~n"),
		Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
		% %lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
		io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
		io:format("~n it's just a gap2**************************************** start ~n"),
		Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
		%lager:log(info, []," Jess_validation  error ~p ~n", [Jess_validation]),
		Result_Body = case  Jess_validation of
			{ok, _} -> 
				{Year,Month,Day} = date(),
				{Hour,Min,Sec}	 = time(),
				Sender 	 			 = get_value_from_render(<<"sender">>, Req_Body_decoded),
				Receiver 		 	 = get_value_from_render(<<"receiver">>, Req_Body_decoded),
				MsgType    			 = get_value_from_render(<<"msgType">>, Req_Body_decoded),
				Msg   				 = get_value_from_render(<<"msg">>, Req_Body_decoded),
				LocalPathSender 	 = get_value_from_render(<<"localPathSender">>, Req_Body_decoded),
				LocalPathReceiver 	 = get_value_from_render(<<"localPathReceiver">>, Req_Body_decoded),
				% MsgDate 	 		 = get_value_from_render(<<"msgDate">>, Req_Body_decoded),
				MsgDate				 = integer_to_list(Year)++"-"++integer_to_list(Month)++"-"++integer_to_list(Day),
				% MsgTime 		 	 = get_value_from_render(<<"msgTime">>, Req_Body_decoded),
				MsgTime				 = integer_to_list(Hour)++":"++integer_to_list(Min)++":"++integer_to_list(Sec),
				MsgTz          	 	 = get_value_from_render(<<"msgTz">>, Req_Body_decoded),
				MsgStatus 			 = get_value_from_render(<<"msgStatus">>, Req_Body_decoded),
				lager:log(info, []," Sender  error ~p ~n", [Sender]),
				lager:log(info, []," Receiver  error ~p ~n", [Receiver]),
				lager:log(info, []," MsgType  error ~p ~n", [MsgType]),
				lager:log(info, []," Msg  error ~p ~n", [Msg]),
				lager:log(info, []," LocalPathSender  error ~p ~n", [LocalPathSender]),
				lager:log(info, []," LocalPathReceiver  error ~p ~n", [LocalPathReceiver]),
				%lager:log(info, [],"  MsgDate  error ~p ~n", [MsgDate]),
				lager:log(info, []," MsgDate  error ~p ~n", [MsgDate]),
				%lager:log(info, [],"  MsgTime  error ~p ~n", [MsgTime]),
				lager:log(info, []," MsgTime  error ~p ~n", [MsgTime]),
				lager:log(info, []," MsgTz  error ~p ~n", [MsgTz]),
				lager:log(info, []," MsgStatus  error ~p ~n", [MsgStatus]),


				Sender_id = emysql:execute(lycos_pool, "SELECT ID FROM lycusers WHERE USERNAME = '"++binary_to_list(Sender)++"' "), 
			    [[{<<"ID">>,SenderID}]] = emysql:as_proplist(Sender_id),  						    lager:log(info, []," SenderID ~p ~n", [SenderID]),
			    % Getting Receiver ID
				Receiver_id = emysql:execute(lycos_pool, "SELECT ID FROM lycusers WHERE USERNAME = '"++binary_to_list(Receiver)++"' "), 
			    [[{<<"ID">>,ReceiverID}]] = emysql:as_proplist(Receiver_id),
			    lager:log(info, []," Receiver_id ~p ~n", [ReceiverID]),
			    R1 = binary:replace(list_to_binary(MsgDate),<<"-">>,<<":">>),lager:log(info, []," R1 is ~p ~n", [R1]),
			    R2 = binary:replace(R1,<<"-">>,<<":">>),lager:log(info, []," R2 is ~p ~n", [R2]),
			    Building_Query = "INSERT INTO lycmessages SET SENDER_ID = "++integer_to_list(SenderID)++",RECEIVER_ID = "++integer_to_list(ReceiverID)++",MSG_TYPE = '"++binary_to_list(MsgType)++"',MSG = '"++binary_to_list(Msg)++"',LOCAL_PATH_SENDER = '"++binary_to_list(LocalPathSender)++"',LOCAL_PATH_RECEIVER  = '"++binary_to_list(LocalPathReceiver)++"',MSG_DATE = '"++binary_to_list(R2)++"',MSG_TIME = '"++MsgTime++"',MSG_TZ = '"++binary_to_list(MsgTz)++"',MSG_STATUS = '"++binary_to_list(MsgStatus)++"'" ,

			    lager:log(info, []," Building_Query result is ~p ~n", [Building_Query]),
				{ok_packet,_,_,SelectResult,_,_,_} = emysql:execute(lycos_pool, Building_Query),
				lager:log(info, []," SelectResult is ~p ~n", [SelectResult]),

				
				Final_Result = jsx:encode([{<<"status">>, 0},{<<"message">>, SelectResult}]),
				lager:log(info, []," Final_Result result is ~p ~n", [Final_Result]),
				Final_Result;

				 
			% "success";
			{error, _} ->
			jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
		end,
		lager:log(info, []," Req_Body_decoded result is ~p ~n", [Req_Body_decoded]),
		lager:log(info, []," Result_Body result is ~p ~n", [Result_Body]),


	
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