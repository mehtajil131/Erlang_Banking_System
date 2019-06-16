-module(money).

-export([start/0]).


start() ->
    register(master_thread,self()),
    BankData = file:consult("src/banks"),
    CustData = file:consult("src/customers"),

    BankList = element(2,BankData),
    CustList = element(2,CustData),

    io:format("~n** Customers and loan objectives **~n~n",[]),

    lists:foreach( fun(Tuple)->
        {Custname,Loan} = Tuple,
        io:format("~w: ~w ~n",[Custname,Loan]),
        Process_Id = spawn(customer,customerBanking,[Custname,Loan,BankList]),
        register(Custname,Process_Id)
                   end,CustList
    ),

    io:format("~n** Banking and financial resources **~n~n",[]),

    lists:foreach( fun(Tuple)->
        {Bankname,BankVal} = Tuple,
        io:format("~w: ~w ~n",[Bankname,BankVal]),
        Process_Id = spawn(bank,bankTransactions,[Bankname,BankVal]),
        register(Bankname,Process_Id)
                   end,BankList
    ),

    io:format("~n",[]),
    message_Passing().


message_Passing()->
    receive
        {loan_request_Message,Customer,Amount,BankName} ->
            io:fwrite("~p requests a loan of ~p dollar(s) from ~p~n",[Customer,Amount,BankName]);
        {loan_approve_Message,Customer,Amount,Bank} ->
            io:fwrite("~p approves a loan of ~p dollar(s) from ~p ~n",[Bank,Amount,Customer]);
        {loan_deny_Message,Customer,Amount,Bank} ->
            io:fwrite("~p denies a loan of ~p dollar(s) from ~p ~n",[Bank,Amount,Customer]);
        {loan_successfull,Customer,Amount} ->
            io:fwrite("~p has reached the objective of ~p dollar(s). Woo Hoo!!!",[Customer,Amount]);
        {bank_amount_remaining,Bank,Amount} ->
            io:fwrite("~p has ~p dollar(s) remaining.",[Bank,Amount]);
        {loan_failed,Customer,Amount} ->
            io:fwrite("~p was only able to borrow ~p dollar(s). Boo Hoo!!",[Customer,Amount])
    after
        1500->
            io:fwrite("Master has received no replies for 1.5 seconds, ending...\n",[])
    end.