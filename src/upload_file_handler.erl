-module(upload_file_handler).
-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-include("config.hrl").
init(_, Req, _Opts) ->
	{ok, Req, undefined}.

terminate(_Reason, _Req, _State) ->
ok.

handle(Req, State) ->

	lager:log(info, [], "Into handler -------- Request is ~p ~n ", [Req]),

	{ok, Headers, Req2} = cowboy_req:part(Req),	lager:log(info, [], "Request2 is ~p ~n ", [Req2]),	lager:log(info, [], "Headers is ~p ~n", [Headers]),
	{ok, Data, Req3} = cowboy_req:part_body(Req2),		%lager:log(info, [], "Request_part is ~p ~n", [Request_part]),
	{file, <<"uploadedFile">>, Filename, ContentType, _TE} = cow_multipart:form_data(Headers),	lager:log(info, [], "Filename is ~p ~n", [Filename]), lager:log(info, [], "ContentType is ~p ~n", [ContentType]),
	Path = ?UploadPath,		lager:log(info, [], "State is ~p ~n", [State]),lager:log(info, [], "Path is ~p ~n", [Path]),	%lager:log(info, [], "Request_part is", [Request_part]),
	Filename2 = binary_to_list(Filename),
	FilePath = lists:concat([Path, Filename2]),
	file:write_file(FilePath, Data),
	FileUploadedPath = ?UploadLink++binary_to_list(Filename), 	lager:log(info, [], "FileUploadedPath is ~p ~n ", [FileUploadedPath]),
	JsonResponse = jsx:encode([{<<"status">>, 0},{<<"message">>,list_to_binary(FileUploadedPath)}]),	lager:log(info, [], "JsonResponse is ~p ~n ", [JsonResponse]),
	Req4 = cowboy_req:reply(200, [{<<"content-type">>, <<"multipart/form-data">>}], binary_to_list(JsonResponse), Req3),
	{ok, Req4, State}.






























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















% -module(upload_file_handler).
		
% -export([init/2]).

% init(Req, Opts) ->

% 	lager:log(info, []," zsdfsfsdgsdfg Path result is ~n "),
% 	% welcome(Req, Opts) ->
% 	Path = "/home/waheguru/Projects/erlang-projects/lycosmessenger/uploads/",
% 	lager:log(info, []," Path result is ~n ~p ~n", [Path]),
% 	lager:log(info, []," Req result is ~n ~p ~n", [Req]),

% 	Requesting_data = cowboy_req:part(Req), 

% 	lager:log(info, []," Requesting_data result is ~n ~p ~n", [Requesting_data]),

% 	{ok, Headers, Req2} = Requesting_data,
% 	lager:log(info, []," Req2 result is ~n ~p ~n", [Req2]),


% 	lager:log(info, []," Headers result is ~n ~p ~n", [Headers]),
% 	{ok, Data, Req3} = cowboy_req:part_body(Req2),  
% 	lager:log(info, []," Data result is ~n ~p ~n", [Data]),
% 	{file, _, Filename, _, _TE} = cow_multipart:form_data(Headers), 
% 	lager:log(info, []," Filename result is ~n ~p ~n", [Filename]),

% 	Filename2 = binary_to_list(Filename),   
% 	lager:log(info, []," Filename2 result is ~n ~p ~n", [Filename2]),
% 	FilePath = lists:concat([Path, Filename2]),   
% 	lager:log(info, []," FilePath result is ~n ~p ~n", [FilePath]),
% 	file:write_file(FilePath, Data),  
% 	lager:log(info, []," Path result is ~n ~p ~n", [Path]),

% 	Req4 = cowboy_req:reply(200, [{<<"content-type">>, <<"multipart/form-data">>}], "File saved to "++FilePath, Req3),
% 	lager:log(info, []," Path result is ~n ~p ~n", [Path]),
% 	{ok, Req4, Opts}.
