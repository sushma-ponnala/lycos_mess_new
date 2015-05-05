
-module(error_hook_responder).

-export([respond/4]).

respond(404, Headers, <<>>, Req) ->
	{Path, Req2} = cowboy_req:path(Req),
	Body = <<"404 Not Found: \"", Path/binary, "\" is not the path you are looking for.\n">>,
	Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
		{<<"content-length">>, integer_to_list(byte_size(Body))}),
	{ok, Req3} = cowboy_req:reply(404, Headers2, Body, Req2),
	Req3;
% respond(Code, Headers, <<>>, Req) when is_integer(Code), Code >= 400 ->
% 	Body = ["HTTP Error ", integer_to_list(Code), $\n],
% 	Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
% 		{<<"content-length">>, integer_to_list(iolist_size(Body))}),
% 	{ok, Req2} = cowboy_req:reply(Code, Headers2, Body, Req),
% 	Req2;
% respond(_Code, _Headers, _Body, Req) ->
% 	Req.

respond(Code, Headers, <<>>, Req) when is_integer(Code), Code >= 400 ->
Body = ["HTTP Error ", integer_to_list(Code), $\n],
Headers2 = lists:keyreplace(<<"content-length">>, 1, Headers,
	{<<"content-length">>, integer_to_list(iolist_size(Body))}),
ContentTypeJson = [{<<"content-type">>, <<"application/json">>}],
Headers3 = lists:append(Headers2, ContentTypeJson),
{ok, Req2} = cowboy_req:reply(Code, Headers3, Body, Req),
Req4 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json;charset=utf-8">>, Req2),
Req4.