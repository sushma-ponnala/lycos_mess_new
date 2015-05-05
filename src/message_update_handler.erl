-module(message_update_handler).
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
	lager:log(info, []," Req_Body_decoded result is ~p ~n", [Req_Body_decoded]),
	{ok, ReqBody, Req2} = cowboy_req:body_qs(Req),
	[{ReqBodyExtracted, true}] = ReqBody,
	%lager:log(info, []," ReqBodyExtracted result is ~p ~n", [ReqBodyExtracted]),
	Schema = <<"{\"properties\": {\"appMsgId\": {\"type\": \"string\", \"required\":true}, \"msgStatus\": {\"type\": \"string\", \"required\":true}}}">>,

	% io:format("~n it's just a gap1 ~n"),
	Jesse_validation_Result = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
	% %lager:log(info, []," Jesse_validation_Result  is ~p ~n", [Jesse_validation_Result]),
	io:format("~n it's just a gap2 ~p ~n",[Jesse_validation_Result]),
	io:format("~n it's just a gap2**************************************** start ~n"),
	Jess_validation = jesse:validate_with_schema(Schema, ReqBodyExtracted, [{parser_fun, fun jsx:decode/1}]),
	%lager:log(info, []," Jess_validation  error ~p ~n", [Jess_validation]),
	Result_Body = case  Jess_validation of
		{ok, _} -> 

		AppMsgId 	 = get_value_from_render(<<"appMsgId">>, Req_Body_decoded),
		lager:log(info, []," AppMsgId  Building_Query ~p ~n", [AppMsgId]),
		MsgStatus 	 = get_value_from_render(<<"msgStatus">>, Req_Body_decoded),
		lager:log(info, []," MsgStatus Building_Query ~p ~n", [MsgStatus]),
		% AppMsgId   = binary_to_list(proplists:get_value(<<"appMsgId">>, PostVals)),
		% MsgStatus  = binary_to_list(proplists:get_value(<<"msgStatus">>, PostVals)), 
		Building_Query = "UPDATE lycmessages SET MSG_STATUS = '"++binary_to_list(MsgStatus)++"' WHERE APP_MSG_ID='"++binary_to_list(AppMsgId)++"'",
		lager:log(info, []," Building_Query ~p ~n", [Building_Query]),
		Result = emysql:execute(lycos_pool, Building_Query),	 
		lager:log(info, []," Result ~p ~n", [Result]),
	    AffectedRows = emysql:affected_rows(Result),  
	    lager:log(info, []," AffectedRows ~p ~n", [AffectedRows]),  
		MMessage = case AffectedRows>0 of
	    	true ->  
	    	jsx:encode([{<<"status">>, 0},{<<"message">>, <<"Message Status updated">>}]) 
	    	 ;
			false -> 
	    	 jsx:encode([{<<"status">>, 1},{<<"message">>, <<"Message Status not updated">>}]) 
			
	    end,



		MMessage;
		{error, _} ->
		jsx:encode([{<<"error">>, <<"UnRecognized web service">>}])
	end,
	lager:log(info, []," Result_Body ~p ~n", [Result_Body]),
	Res1 = cowboy_req:set_resp_body(Result_Body, Req2),
	Res2 = cowboy_req:delete_resp_header(<<"content-type">>, Res1),
	Res3 = cowboy_req:set_resp_header(<<"content-type">>, <<"application/json">>, Res2),
	{true, Res3, State}.