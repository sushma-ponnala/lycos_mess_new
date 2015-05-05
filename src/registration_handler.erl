-module(registration_handler).

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
lager:log(info, []," Req_Body_decoded result is ~p ~n", [Req_Body_decoded]),


Schema = <<"{\"properties\":{\"userName\": {\"type\": \"string\", \"required\":true},\"pass\": {\"type\": \"string\", \"required\":true},\"namespace\": {\"type\": \"string\", \"required\":true},\"loginAlias\": {\"type\": \"string\", \"required\":true},\"firstName\": {\"type\": \"string\", \"required\":true},\"lastName\": {\"type\": \"string\", \"required\":true},\"gender\": {\"type\": \"string\", \"required\":true},\"phone\": {\"type\": \"string\", \"required\":true},\"email\": {\"type\": \"string\", \"required\":true},\"zip\": {\"type\": \"string\", \"required\":true},\"city\": {\"type\": \"string\", \"required\":true},\"state\": {\"type\": \"string\", \"required\":true},\"country\": {\"type\": \"string\", \"required\":true}}}">>,
% io:format("~n it's just a gap1 ~n"),
Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
% %lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
io:format("~n it's just a gap2**************************************** start ~n"),
Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
%lager:log(info, []," Jess_validation  error ~p ~n", [Jess_validation]),
Result_Body = case  Jess_validation of
{ok, _} -> 
	{{Year,Month,Day},{Hour,Min,Sec}} = {date(),time()},


	UserName 	 = get_value_from_render(<<"userName">>, Req_Body_decoded),	lager:log(info, []," UserName result is ~p ~n", [UserName]),
	Pass 		 = get_value_from_render(<<"pass">>, Req_Body_decoded),	lager:log(info, []," Pass result is ~p ~n", [Pass]),
	Namespace    = get_value_from_render(<<"namespace">>, Req_Body_decoded),	lager:log(info, []," Namespace result is ~p ~n", [Namespace]),
	LoginAlias   = get_value_from_render(<<"loginAlias">>, Req_Body_decoded),	lager:log(info, []," LoginAlias result is ~p ~n", [LoginAlias]),
	FirstName 	 = get_value_from_render(<<"firstName">>, Req_Body_decoded),	lager:log(info, []," FirstName result is ~p ~n", [FirstName]),
	LastName 	 = get_value_from_render(<<"lastName">>, Req_Body_decoded),	lager:log(info, []," LastName result is ~p ~n", [LastName]),
	% Address 	 = get_value_from_render(<<"address">>, Req_Body_decoded),
	% lager:log(info, []," Address result is ~p ~n", [Address]),
	City 		 = get_value_from_render(<<"city">>, Req_Body_decoded),	lager:log(info, []," City result is ~p ~n", [City]),
	Zip          = get_value_from_render(<<"zip">>, Req_Body_decoded),	lager:log(info, []," Zip result is ~p ~n", [Zip]),
	CountryState = get_value_from_render(<<"state">>, Req_Body_decoded),	lager:log(info, []," CountryState result is ~p ~n", [CountryState]),
	Country 	 = get_value_from_render(<<"country">>, Req_Body_decoded),	lager:log(info, []," Country result is ~p ~n", [Country]),
	Email 		 = get_value_from_render(<<"email">>, Req_Body_decoded),	lager:log(info, []," Email result is ~p ~n", [Email]),
	% ISD 		 = get_value_from_render(<<"ISD">>, Req_Body_decoded),
	% lager:log(info, []," ISD result is ~p ~n", [ISD]),
	Phone        = get_value_from_render(<<"phone">>, Req_Body_decoded),	lager:log(info, []," Phone result is ~p ~n", [Phone]),

	% Telegram  	 = get_value_from_render(<<"telegram">>, Req_Body_decoded),
	lager:log(info, []," Sec result is ~p ~n", [Sec]),
	Gender 		 = get_value_from_render(<<"gender">>, Req_Body_decoded),	lager:log(info, []," Gender result is ~p ~n", [Gender]),
	% Birthday     = get_value_from_render(<<"birthday">>, Req_Body_decoded),

	% RefIp 	 	 = get_value_from_render(<<"RefIp">>, Req_Body_decoded),
	% Enabled      = get_value_from_render(<<"Enabled">>, Req_Body_decoded),
	CreationTime = integer_to_list(Year)++"-"++integer_to_list(Month)++"-"++integer_to_list(Day)++" "++ integer_to_list(Hour)++":"++integer_to_list(Min)++":"++integer_to_list(Sec),
	lager:log(info, []," CreationTime result is ~p ~n", [CreationTime]),
	LastLogin 	 = integer_to_list(Year)++"-"++integer_to_list(Month)++"-"++integer_to_list(Day)++" "++ integer_to_list(Hour)++":"++integer_to_list(Min)++":"++integer_to_list(Sec),
	lager:log(info, []," LastLogin result is ~p ~n", [LastLogin]),

	Check_availability_Query = "select id from lycusers where USERNAME ='"++ binary_to_list(UserName) ++ "'",	lager:log(info, []," Check_availability_Query result is ~p ~n", [Check_availability_Query]),
	{result_packet,_,_,CheckUser,_} = emysql:execute(lycos_pool, Check_availability_Query),lager:log(info, []," CheckUser result is ~p ~n", [CheckUser]),

	LengthOfResult = length(CheckUser),	lager:log(info, []," LengthOfResult result is ~p ~n", [LengthOfResult]),
	ResultBody = case LengthOfResult =:= 0 of
        true -> 
			Building_Query = "INSERT INTO lycusers SET USERNAME ='"++ binary_to_list(UserName) ++"',PASS = '"++binary_to_list(Pass)++"',NAMESPACE = '"++binary_to_list(Namespace)++"',LOGINALIAS = '"++binary_to_list(LoginAlias)++"',FIRSTNAME = '"++binary_to_list(FirstName)++"',LASTNAME = '"++binary_to_list(LastName)++"',CITY = '"++binary_to_list(City)++"',ZIP = '"++binary_to_list(Zip)++"',STATE = '"++binary_to_list(CountryState)++"',COUNTRY = '"++binary_to_list(Country)++"',EMAIL = '"++binary_to_list(Email)++"',PHONE = '"++binary_to_list(Phone)++"',GENDER = '"++binary_to_list(Gender)++"',CREATIONTIME = '"++CreationTime++"',LASTLOGIN = '"++LastLogin++"'",

			lager:log(info, []," Building_Query result is ~p ~n", [Building_Query]),


			Result = emysql:execute(lycos_pool, Building_Query),
			lager:log(info, []," Result result is ~p ~n", [Result]),
			Body4 = jsx:encode([
		    	{<<"status">>, 0},
		    	{<<"message">>,[<<"Registration successful">>]}
		    	
		    	]),


		    lager:log(info, []," Body4  is ~p ~n", [Body4]),
		    Body4	;
            
        false ->
        	
           jsx:encode([{<<"status">>, 1},{<<"message">>, <<"User already exists">>}])	        	
	end,
	lager:log(info, []," ResultBody result is ~p ~n", [ResultBody]),


	Check_availability_Query1 = "select username from users where USERNAME ='"++ binary_to_list(UserName) ++ "'",	lager:log(info, []," Check_availability_Query result from xmpp server is ~p ~n", [Check_availability_Query1]),
	{result_packet,_,_,CheckUser1,_} = emysql:execute(xmpp_pool, Check_availability_Query1),lager:log(info, []," CheckUser result is ~p ~n", [CheckUser1]),

	LengthOfResult1 = length(CheckUser1),	lager:log(info, []," LengthOfResult1 result is ~p ~n", [LengthOfResult1]),
	ResultBody12 = case LengthOfResult1 =:= 0 of
        true -> 
        	Building_Query12 = "INSERT INTO users SET username ='"++ binary_to_list(UserName) ++"',password = '"++binary_to_list(Pass)++"'",
			lager:log(info, []," Building_Query12 result is ~p ~n", [Building_Query12]),
			Result12 = emysql:execute(xmpp_pool, Building_Query12),
			lager:log(info, []," Result12 result is ~p ~n", [Result12]),
			"success"	;            
        false ->        	
           jsx:encode([{<<"message">>, <<"User already exists">>}])	        	
	end,

	lager:log(info, []," ResultBody1 result is ~p ~n", [ResultBody12]),


	ResultBody;
	{error, _} ->
		jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
	end,
 

	lager:log(info, []," Result_Body result is ~p ~n", [Result_Body]),

	% io:format("from registration_handler"),
 	% {ok, ReqBody, Req2} = cowboy_req:body(Req),
 	% Req_Body_decoded = jsx:decode(ReqBody),
 	% [{<<"title">>,Title},{<<"content">>,Content}] = Req_Body_decoded,
 	% Title1 = binary_to_list(Title),
 	% Content1 = binary_to_list(Content),
 	% io:format("Title1 is ~p ~n ", [Title1]),
 	% io:format("Content1 is ~p ~n", [Content1]),
 	% io:format("Title is ~p ~n", [Title]),
 	% io:format("Content is ~p ~n", [Content]),
 	% lager:log(info, [], "Request Body", [Req_Body_decoded]),
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