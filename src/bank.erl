-module(bank).

-export([bankTransactions/3]).


bankTransactions(BankName,BankVal,MID) ->
  recvLoanReq(BankName,BankVal,MID).

recvLoanReq(BankName,BankVal,MID)->

  timer:sleep(200),
  receive

    {loan_request,Customer,LoanAmount,RandomBankId} ->

      if
        ( LoanAmount =< BankVal) ->
          MID ! {loan_approve_Message,BankName,LoanAmount,Customer},
          whereis(Customer) ! {loan_approve_Message_Cust,Customer,LoanAmount},
          recvLoanReq(BankName,BankVal-LoanAmount,MID);
        true ->
          MID ! {loan_deny_Message,BankName,LoanAmount,Customer},
          whereis(Customer) ! {loan_deny_Message_Cust,Customer,LoanAmount,RandomBankId}

      end
  after
    5000->
      io:fwrite("Process  has received no calls for 1 second, ending...~n")

  end.
