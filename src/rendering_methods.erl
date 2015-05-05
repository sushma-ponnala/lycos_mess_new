-module(rendering_methods).

-export([responseBody/2, decoding_request/1, user_id_from_name/1, get_value_from_render/2]).

responseBody(Res1Body, Req2) ->
	Res1 = cowboy_req:set_resp_body(Res1Body, Req2),
	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
	cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2)	
.

decoding_request(Req) -> 
	{ok, ReqBody, Req2} = cowboy_req:body_qs(Req),
 	[{ReqBodyExtracted, true}] = ReqBody,
 	
 	Req_Body_decoded= jsx:decode(ReqBodyExtracted),
 	lager:log(info, [], "json decoded ~p ~n", [Req_Body_decoded]),
 	{Req_Body_decoded, Req2}
.

user_id_from_name(Name) -> 
	emysql:prepare(my_st, << "select ID from lycusers where USERNAME = ?">>),
 	Result = emysql:execute(lycos_pool, my_st, [Name]),
 	Result_list = emysql:as_proplist(Result),
 	[[{<<"ID">>,User_Id}]] = Result_list,
 	% lager:log(info, []," User_Id result is ~p ~n", [User_Id]),
 	User_Id
.

get_value_from_render(Param12, Link) ->
	ContactStatus = proplists:get_value(Param12, Link), 
	lager:log(info, [], "Params is ~p ~n  value is ~p ~n", [Param12, ContactStatus]),
	ContactStatus
.



% -module(rendering_methods).

% -export([responseBody/3, decoding_request/2, user_id_from_name/1, get_value_from_render/2, error_response/2, username_check/4]).
% -export([userstatus_check/5, contactName_check/6,contactStatus_check/7,success/7]).


% decoding_request(Req, State) -> 
% 	{ok, ReqBody, Req2} = cowboy_req:body_qs(Req),
%  	[{ReqBodyExtracted, true}] = ReqBody,
%  	lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),

%  	Schema = <<"{\"properties\": {\"userName\": {\"type\": \"string\", \"required\":true}, \"userStatus\": {\"type\": \"string\", \"required\":true}, \"contactName\": {\"type\": \"string\", \"required\":true}, \"contactStatus\": {\"type\": \"string\", \"required\":true}}}">>,
%  	% io:format("~n it's just a gap1 ~n"),
%  	Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
%  	% lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
%  	io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
%  	io:format("~n it's just a gap2**************************************** start ~n"),

%  	Jesse_result = case jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]) of
% 		{ok, _} -> 
% 			"valid data ";
% 		{error, _} ->
% 			error_response(Req2, State)
% 		end
% 	,
%  	io:format("~n Jesse_result is ~p ~n", [Jesse_result]),

%  	io:format("~n it's just a gap2**************************************** end ~n"),

%  	Req_Body_decoded= jsx:decode(ReqBodyExtracted),
%  	lager:log(info, [], "json decoded ~p ~n", [Req_Body_decoded]),
%  	{Req_Body_decoded, Req2}
% .

% user_id_from_name(Name) -> 
% 	emysql:prepare(my_st, << "select ID from lycusers where USERNAME = ?">>),
%  	Result = emysql:execute(lycos_pool, my_st, [Name]),
%  	Result_list = emysql:as_proplist(Result),
%  	[[{<<"ID">>,User_Id}]] = Result_list,
%  	% lager:log(info, []," User_Id result is ~p ~n", [User_Id]),
%  	User_Id
% .

% get_value_from_render(Param12, Link) ->
% 	ContactStatus = proplists:get_value(Param12, Link), 
% 	lager:log(info, [], "Params is ~p ~n  value is ~p ~n", [Param12, ContactStatus]),
% 	ContactStatus
% .

% username_check(Field, Req_Body_decoded, Req2, State) -> 
% 	case proplists:is_defined(Field,Req_Body_decoded) of
% 		true ->
% 			 get_value_from_render(Field, Req_Body_decoded);
% 			% userstatus_check(UserName, <<"userStatus">>, Req_Body_decoded, Req2, State);

% 		false ->
% 			error_response(Req2, State)
% 	end
% .	
% responseBody(Res1Body, Req2, State) ->
% 	Res1 = cowboy_req:set_resp_body(Res1Body, Req2),
% 	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
% 	Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),	
% 	{true, Res3, State}
% .
% error_response(Req2, State)->
% 	Error_res = jsx:encode([{<<"error">>, <<"UnRecognized web service">>}]),
% 	responseBody(Error_res, Req2, State)
% .
% userstatus_check(UserName, Field, Req_Body_decoded, Req2, State) ->
% 	case proplists:is_defined(Field,Req_Body_decoded) of
% 		true -> 
% 			UserStatus = get_value_from_render(Field, Req_Body_decoded),
% 			contactName_check(UserName, UserStatus, <<"contactName">>, Req_Body_decoded, Req2, State);
% 		false ->
% 		error_response(Req2, State)
% 	end
% .

% contactName_check(UserName, UserStatus, Field, Req_Body_decoded, Req2, State) ->
% 	case proplists:is_defined(Field,Req_Body_decoded) of
% 		true -> 
% 			ContactName = get_value_from_render(Field, Req_Body_decoded),
% 			contactStatus_check(UserName, UserStatus, ContactName, <<"contactStatus">>, Req_Body_decoded, Req2, State);
% 		false ->
% 			error_response(Req2, State)
% 	end
% .
% contactStatus_check(UserName, UserStatus, ContactName, Field,Req_Body_decoded, Req2, State) ->
% 	case proplists:is_defined(Field,Req_Body_decoded) of
% 		true -> 
% 			ContactStatus = get_value_from_render(Field, Req_Body_decoded),
% 			success(UserName, UserStatus, ContactName, ContactStatus, Req_Body_decoded, Req2, State);
% 		false ->
% 			error_response(Req2, State)
% 	end
% .
% success(UserName, UserStatus, ContactName, ContactStatus, Req_Body_decoded, Req2, State) ->
% 	lager:log(info, []," Req_Body_decoded result is ~p ~n", [Req_Body_decoded]),
% 	Res1Body = jsx:encode([{<<"username">>,UserName}, {<<"userstatus">>,UserStatus}, {<<"contactname">>,ContactName}, {<<"contactstatus">>,ContactStatus}]),
% 	responseBody(Res1Body, Req2, State)
% .