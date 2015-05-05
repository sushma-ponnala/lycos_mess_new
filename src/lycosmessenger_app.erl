-module(lycosmessenger_app).

-behaviour(application).

-include("config.hrl").

-export([start/2, stop/1]).


-import(routing,[routes/0]). 

start(_Type, _Args) ->
	% emysql:add_pool(helloz_pool, [{size,1}, {user,"test1"}, {password,"password"}, {database,"tracker"},{encoding,utf8}]),
	emysql:add_pool(tracker_pool, [{size,1}, {user,?Usr2}, {password,?Pass2}, {database,?Db2},{encoding,utf8}]),
	emysql:add_pool(lycos_pool,[{size,1}, {user,?Usr1}, {password,?Pass1}, {database,?Db1},{encoding,utf8}]),
	emysql:add_pool(xmpp_pool,[{size,1}, {user,?Usr1}, {password,?Pass1}, {database,?Db3},{encoding,utf8}]),

	% Dispatch = cowboy_router:compile(routes()),    

 %    {ok, _} = cowboy:start_http(http,100, [{port, 10003}],[{env, [{dispatch, Dispatch}]}
 %              ]),
	Dispatch = cowboy_router:compile(routes()), 

	TransOpts = [{port, ?APP_PORT},{max_connections, ?MAX_CONNECTIONS}],
    ProtoOpts = [{env, [{dispatch, Dispatch}]}
    			],    

	{ok, _}   = cowboy:start_http(http, ?APP_CONNECTORS, TransOpts, ProtoOpts),
	lycosmessenger_sup:start_link().

stop(_State) ->
	ok.

 

 % start(_StartType, _StartArgs) ->
	
 %    contentapi_sup:start_link().


	% emysql:add_pool(tracker_pool, [{size,1}, {user,"test1"}, {password,"password"}, {database,"tracker"},{encoding,utf8}]),
	% % emysql:add_pool(lycos_pool,[{size,1}, {user,"mongooseim"}, {password,"mongooseim"}, {database,"mongooseim"},{encoding,utf8}]),
