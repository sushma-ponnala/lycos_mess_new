-module(request_hook_responder).

-export([set_cors/1]).

set_cors(Req) ->
	io:format("Request is ~p ~n", [Req]),
	Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, OPTIONS">>, Req),
	io:format("Req1 is ~p ~n", [Req1]),
    Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),
    io:format("Req2 is ~p ~n", [Req2]),
    Req3 = cowboy_req:set_resp_header(<<"access-control-allow-headers">>, <<"Origin, X-Requested-With, Content-Type, Accept">>, Req2),
    io:format("Req3 is ~p ~n", [Req3]),
    Req4 = cowboy_req:set_resp_header(<<"server">>, <<"Whip-0.1">>, Req3),
    io:format("Req4 is ~p ~n", [Req4]),
    Req4
.