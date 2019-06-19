-module(customer).

-export([customerBanking/5]).


customerBanking(Customer,Loan_amt,BankList,MID,TotalAmtReq) ->
  sendLoanReq(Customer,Loan_amt,BankList,MID,TotalAmtReq).

sendLoanReq(Customer,Loan_amt,BankList,MID,TotalAmtReq)->

  timer:sleep(100),

  BankTotalLength = length(BankList),
  if
    (BankTotalLength == 0 ) or (Loan_amt == 0) ->
      if Loan_amt == 0 ->
        MID ! {loan_successfull,Customer,TotalAmtReq};
        true->
          MID ! {loan_failed,Customer,TotalAmtReq}
      end;
    true ->
      if
        (Loan_amt < 50) and (Loan_amt>0) ->
          RandomAmt = rand:uniform(Loan_amt);
        true ->
          RandomAmt = rand:uniform(50)
      end,

      if
        BankTotalLength == 1 ->
          RandomBankId = 1;
        true ->
          RandomBankId = rand:uniform(BankTotalLength)
      end,

      {RandomBankName,_} = lists:nth(RandomBankId,BankList),

      MID ! {loan_request_Message,Customer,RandomAmt,RandomBankName},
      whereis(RandomBankName) ! {loan_request,Customer,RandomAmt,RandomBankId},
      receiveResponseFromBank(Customer,Loan_amt,BankList,MID,TotalAmtReq)
  end.


receiveResponseFromBank(Customer,Amount,BankList,MID,TotalAmtReq) ->
  receive
    {loan_approve_Message_Cust,Customer,LoanAmount} ->
        sendLoanReq(Customer,Amount - LoanAmount,BankList,MID,TotalAmtReq+LoanAmount);

    {loan_deny_Message_Cust,Customer,RandomBankId} ->
      Tuple = lists:nth(RandomBankId,BankList),
      UpdatedBankList = lists:delete(Tuple,BankList),
        sendLoanReq(Customer,Amount,UpdatedBankList,MID,TotalAmtReq)

  after 1000->
    io:fwrite("~p Process has received no calls for 1 seconds, ending...~n",[Customer]),
    if Amount == 0 ->
      MID ! {loan_successfull,Customer,TotalAmtReq};
      true->
        MID ! {loan_failed,Customer,TotalAmtReq}
    end

  end.
