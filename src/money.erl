-module(money).

-export([start/0]).


start() ->

    BankData = file:consult("src/banks.txt"),
    CustData = file:consult("src/customers.txt"),

    BankList = element(2,BankData),
    CustList = element(2,CustData),

    register(master,self()),
    io:format("~n** Customers and loan objectives **~n~n",[]),

    lists:foreach( fun(Tuple)->
        {CustName,Loan} = Tuple,
        io:format("~w: ~w ~n",[CustName,Loan]),
        Process_Id = spawn(customer,customerBanking,[CustName,Loan,BankList,self(),0]),
        register(CustName,Process_Id)
                   end,CustList
    ),

    io:format("~n** Banking and financial resources **~n~n",[]),

    lists:foreach( fun(Tuple)->
        {BankName,BankVal} = Tuple,
        io:format("~w: ~w ~n",[BankName,BankVal]),
        Process_Id = spawn(bank,bankTransactions,[BankName,BankVal,self()]),
        register(BankName,Process_Id)
                   end,BankList
    ),

    io:format("~n",[]),
    message_Passing().


message_Passing()->
    receive
        {loan_request_Message,Customer,Amount,BankName} ->
            io:fwrite("~p requests a loan of ~p dollar(s) from ~p~n",[Customer,Amount,BankName]),
            message_Passing();
        {loan_approve_Message,Bank,Amount,Customer} ->
            io:fwrite("~p approves a loan of ~p dollar(s) from ~p~n",[Bank,Amount,Customer]),
            message_Passing();
        {loan_deny_Message,Bank,Amount,Customer} ->
            io:fwrite("~p denies a loan of ~p dollar(s) from ~p ~n",[Bank,Amount,Customer]),
            message_Passing();
        {loan_successfull,Customer,Amount} ->
            io:fwrite("~p has reached the objective of ~p dollar(s). Woo Hoo!!!~n",[Customer,Amount]),
            message_Passing();
        {bank_amount_remaining,Bank,Amount} ->
            io:fwrite("~p has ~p dollar(s) remaining.~n",[Bank,Amount]),
            message_Passing();
        {loan_failed,Customer,Amount} ->
            io:fwrite("~p was only able to borrow ~p dollar(s). Boo Hoo!!~n",[Customer,Amount]),
            message_Passing()

    after
        2000->
            io:fwrite("Master has received no replies for 2 seconds, ending...\n",[])
    end.