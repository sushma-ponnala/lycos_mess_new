PROJECT = lycosmessenger

DEPS = lager cowboy ibrowse jsx emysql sync jesse jiffy

dep_lager = https://github.com/basho/lager.git master
dep_cowboy = https://github.com/extend/cowboy 1.0.1
dep_jsx = https://github.com/talentdeficit/jsx.git v2.0.1
dep_ibrowse = https://github.com/cmullaparthi/ibrowse.git v4.0.1
dep_emysql = https://github.com/Eonblast/Emysql.git master
dep_sync = https://github.com/rustyio/sync.git master
dep_jesse = https://github.com/klarna/jesse master
dep_jiffy = https://github.com/davisp/jiffy master

include erlang.mk


shell:
	erl -pa ebin -pa deps/*/ebin -config "priv/app.config" -eval "ibrowse:start(),[application:start(App) || App <- [syntax_tools, compiler, goldrush, lager, jsx, ranch, cowlib, cowboy, emysql, sync, jesse, jiffy, lycosmessenger]]."

