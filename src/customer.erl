-module(customer).

-export([customerBanking/3]).


customerBanking(Customer,Loan_amt,BankList) ->
  sendLoanReq(Customer,Loan_amt,BankList).

sendLoanReq(Customer,Loan_amt,BankList)->

  if
    Loan_amt < 50 ->
      RandomAmt = rand:uniform(Loan_amt);
    true ->
      RandomAmt = rand:uniform(50)
  end,

  RandomBankId = rand:uniform(length(BankList)),
  {RandomBankName,_} = lists:nth(RandomBankId,BankList),

  whereis(master_thread) ! {loan_request_Message,Customer,RandomAmt,RandomBankName},
  whereis(RandomBankName) ! {loan_request,Customer,RandomAmt,RandomBankId}.


receiveResponseFromBank(Customer,Amount,BankList) ->

  receive

    {loan_approve_Message_Cust,Customer,LoanAmount} ->

      BankTotalLength = length(BankList),
      if
        (BankTotalLength == 0 ) or (LoanAmount == 0) ->
          if LoanAmount == 0 ->
            whereis(master_thread) ! {loan_successfull,Customer,LoanAmount};
          true->
            whereis(master_thread) ! {loan_failed,Customer,LoanAmount}
          end;
      true ->
        sendLoanReq(Customer,Amount-LoanAmount,BankList),
        receiveResponseFromBank(Customer,Amount-LoanAmount,BankList)
      end;

    {loan_deny_Message_Cust,Customer,LoanAmount,RandomBankid} ->
      UpdatedBankList = lists:delete(RandomBankid,BankList),
      if
        UpdatedBankList == [] or (LoanAmount == 0) ->
          if LoanAmount == 0 ->
            whereis(master_thread) ! {loan_successfull,Customer,LoanAmount};
            true->
              whereis(master_thread) ! {loan_failed,Customer,LoanAmount}
          end;
          true ->
        sendLoanReq(Customer,Amount-LoanAmount,BankList),
        receiveResponseFromBank(Customer,Amount-LoanAmount,BankList)
      end
  end.
