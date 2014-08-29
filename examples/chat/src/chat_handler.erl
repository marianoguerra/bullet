-module(chat_handler).

-export([init/4, stream/3, info/3, terminate/2]).

-record(state, {channel}).

init(_Transport, Req, Opts, _Active) ->
    io:format("channel init ~p~n", [Opts]),
    {channel, ChannelPid} = lists:keyfind(channel, 1, Opts),
    chat_channel:subscribe(ChannelPid, self()),
    {ok, Req, #state{channel=ChannelPid}}.

stream(<<"ping">>, Req, State) ->
    io:format("ping received~n"),
    {reply, <<"pong">>, Req, State};

stream(Data, Req, State=#state{channel=ChannelPid}) ->
    io:format("message received ~s~n", [Data]),
    chat_channel:send(ChannelPid, {msg, self(), Data}),
    {ok, Req, State}.

info({msg, _Sender, Data}, Req, State) ->
    io:format("msg received ~p~n", [Data]),
    {reply, Data, Req, State}.

terminate(_Req, #state{channel=ChannelPid}) ->
    io:format("unsubscribing from channel~n"),
    chat_channel:unsubscribe(ChannelPid, self()),
    ok.

