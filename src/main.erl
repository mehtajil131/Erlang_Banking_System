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
    BankData = file:consult("src/banks"),
    CustData = file:consult("src/customers"),
    BankList = element(2,BankData),

    %io:fwrite("~w",[BankData]),
    CustList = element(2,CustData),

    io:format("~n** Customers and loan objectives **~n~n",[]),

    lists:foreach( fun(Tuple)->
        {Custname,Loan} = Tuple,
        io:format("~w: ~w ~n",[Custname,Loan]),
        Process_Id = spawn(calling,callToReceiver,[Custname,Loan,self(),0]),
        register(Custname,Process_Id)
                   end,CustList
    ),

    io:format("~n** Banking and financial resources **~n~n",[]),

    lists:foreach( fun(Tuple)->
        {Bankname,BankVal} = Tuple,
        io:format("~w: ~w ~n",[Bankname,BankVal]),
        Process_Id = spawn(calling,callToReceiver,[Bankname,BankVal,self(),0]),
        register(Bankname,Process_Id)
                   end,BankList
    ),

    io:format("~n",[]).
    %print_Intro_And_Reply_Message(0).


%% This method will print all the incoming message from callToReceiver's method
print_Intro_And_Reply_Message(Counter)->
    receive
        {intro_Message,Sender,Receiver,Timestamp} ->
            io:fwrite("~p received intro message from ~p [~p]~n",[Sender,Receiver,Timestamp]),
            print_Intro_And_Reply_Message(Counter+1);
        {reply_Message,Sender,Receiver,Timestamp} ->
            io:fwrite("~p received reply message from ~p [~p]~n",[Sender,Receiver,Timestamp]),
            print_Intro_And_Reply_Message(Counter+1)
    after
        1500->
            io:fwrite("Master has received no replies for 1.5 seconds, ending...\n",[])
    end.