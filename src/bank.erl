-module(bank).

-export([bankTransactions/3]).


bankTransactions(BankName,BankVal,MID) ->
  recvLoanReq(BankName,BankVal,MID).

recvLoanReq(BankName,BankVal,MID)->

  %timer:sleep(100),
  receive

    {loan_request,Customer,LoanAmount,RandomBankId} ->

      if
        ( LoanAmount =< BankVal) and (BankVal > 0)->
          MID ! {loan_approve_Message,BankName,LoanAmount,Customer},
          whereis(Customer) ! {loan_approve_Message_Cust,Customer,LoanAmount},
          recvLoanReq(BankName,BankVal-LoanAmount,MID);
        true ->
          MID ! {loan_deny_Message,BankName,LoanAmount,Customer},
          whereis(Customer) ! {loan_deny_Message_Cust,Customer,RandomBankId},
          recvLoanReq(BankName,BankVal,MID)
      end
  after
    800->
      io:fwrite("~p Process has received no calls for 800 milliseconds, ending...~n",[BankName]),
      MID ! {bank_amount_remaining,BankName,BankVal}

  end.
