-module(money).

-export([start/0]).


start() ->

    BankData = file:consult("src/banks"),
    CustData = file:consult("src/customers"),

    BankList = element(2,BankData),
    CustList = element(2,CustData),

    register(master,self()),
    io:format("~n** Customers and loan objectives **~n~n",[]),

    lists:foreach( fun(Tuple)->
        {CustName,Loan} = Tuple,
        io:format("~w: ~w ~n",[CustName,Loan]),
        Process_Id = spawn(customer,customerBanking,[CustName,Loan,BankList,self()]),
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
            io:fwrite("~p requests a loan of ~p dollar(s) from ~p~n",[Customer,Amount,BankName]);
        {loan_approve_Message,Bank,Amount,Customer} ->
            io:fwrite("~p approves a loan of ~p dollar(s) from ~p~n",[Bank,Amount,Customer]);
        {loan_deny_Message,Bank,Amount,Customer} ->
            io:fwrite("~p denies a loan of ~p dollar(s) from ~p ~n",[Bank,Amount,Customer]);
        {loan_successfull,Customer,Amount} ->
            io:fwrite("~p has reached the objective of ~p dollar(s). Woo Hoo!!!",[Customer,Amount]);
        {bank_amount_remaining,Bank,Amount} ->
            io:fwrite("~p has ~p dollar(s) remaining.",[Bank,Amount]);
        {loan_failed,Customer,Amount} ->
            io:fwrite("~p was only able to borrow ~p dollar(s). Boo Hoo!!",[Customer,Amount])
    after
        5000->
            io:fwrite("Master has received no replies for 1.5 seconds, ending...\n",[])
    end.