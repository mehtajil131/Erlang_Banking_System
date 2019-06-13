%%%-------------------------------------------------------------------
%%% @author jil
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jun 2019 6:06 PM
%%%-------------------------------------------------------------------
-module(main).
-author("jil").

%% API
-export([start/0]).


start() ->
    bankData = file:consult("/home/jil/Concordia Summer 2019/Comparitive/Erlang_Project/src/banks").