-module(customer).

-export([customerBanking/4]).


customerBanking(Customer,Loan_amt,BankList,MID) ->
  sendLoanReq(Customer,Loan_amt,BankList,MID).

sendLoanReq(Customer,Loan_amt,BankList,MID)->

  timer:sleep(200),
  if
    (Loan_amt < 50) and (Loan_amt>0) ->
      RandomAmt = random:uniform(Loan_amt);
    true ->
      RandomAmt = random:uniform(50)
  end,


  RandomBankId = rand:uniform(length(BankList)),
  {RandomBankName,_} = lists:nth(RandomBankId,BankList),

  MID ! {loan_request_Message,Customer,RandomAmt,RandomBankName},

  whereis(RandomBankName) ! {loan_request,Customer,RandomAmt,RandomBankId},
  receiveResponseFromBank(Customer,RandomAmt,BankList,MID).


receiveResponseFromBank(Customer,Amount,BankList,MID) ->
  receive
    {loan_approve_Message_Cust,Customer,LoanAmount} ->

      BankTotalLength = length(BankList),
      if
        (BankTotalLength == 0 ) or (LoanAmount == 0) ->
          if LoanAmount == 0 ->
            MID ! {loan_successfull,Customer,LoanAmount};
          true->
            MID ! {loan_failed,Customer,LoanAmount}
          end;
      true ->
        sendLoanReq(Customer,Amount-LoanAmount,BankList,MID),
        receiveResponseFromBank(Customer,Amount-LoanAmount,BankList,MID)
      end;

    {loan_deny_Message_Cust,Customer,LoanAmount,RandomBankId} ->
      UpdatedBankList = lists:delete(RandomBankId,BankList),
      if
        UpdatedBankList == [] or (LoanAmount == 0) ->
          if LoanAmount == 0 ->
            MID ! {loan_successfull,Customer,LoanAmount};
            true->
              MID ! {loan_failed,Customer,LoanAmount}
          end;
          true ->
        sendLoanReq(Customer,Amount-LoanAmount,UpdatedBankList,MID),
        receiveResponseFromBank(Customer,Amount-LoanAmount,UpdatedBankList,MID)
      end
  end.
