-module(chat_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    {ok, ChannelPid} = chat_channel:new(),
    Dispatch = cowboy_router:compile([
        {'_', [
               {"/chat", bullet_handler, [{handler, chat_handler}, {channel, ChannelPid}]},
               {"/ui/[...]", cowboy_static, {priv_dir, chat, "assets",
                                             [{mimetypes, cow_mimetypes, all}]}}
        ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
        {env, [{dispatch, Dispatch}]}
    ]),
    chat_sup:start_link().

stop(_State) ->
	ok.
