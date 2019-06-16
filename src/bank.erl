-module(bank).

-export([bankTransactions/2]).


bankTransactions(BankName,BankVal) ->
  recvLoanReq(BankName,BankVal).

recvLoanReq(BankName,BankVal)->

  timer:sleep(100),

  receive

    {loan_request,Customer,LoanAmount,RandomBankId} ->

      if
        ( LoanAmount =< BankVal) ->
          whereis(master_thread) ! {loan_approve_Message,Customer,LoanAmount,BankName},
          whereis(Customer) ! {loan_approve_Message_Cust,Customer,LoanAmount},
          recvLoanReq(BankName,BankVal-LoanAmount);
        true ->
          whereis(master_thread) ! {loan_deny_Message,Customer,LoanAmount,BankName},
          whereis(Customer) ! {loan_deny_Message_Cust,Customer,LoanAmount,RandomBankId}

      end
  after
    1000->
      io:fwrite("Process  has received no calls for 1 second, ending...~n")

  end.
