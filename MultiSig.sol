// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MultiSig {

    address [] public owners;
    uint256 public numConfirmationsRequired;

    struct Transaction{
        address to;
        uint256 value;
        bool executive;
    }

    mapping(uint256 => mapping(address => bool)) isConfirmed;
    Transaction[] transactions;
    event TransactionSubmitted(uint transactionId,address sender,address receiver,uint amount);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);

    constructor(address[] memory _owners, uint256 _numConfirmationsRequired){
        require(_owners.length >1, "Owners required");
        require(_numConfirmationsRequired>0 && numConfirmationsRequired<=_owners.length,"Num of confirmations are not in sync with the number of owners");

        for(uint256 i= 0; i< _owners.length; i++){
            require(_owners[i]!=address(0),"Invalid User");
            owners.push(_owners[i]);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }
    function submitTransaction(address _to) public payable{
        require(_to!= address(0),"Invalid receiver's address ");
        require(msg.value>0,"Transfer amount must be greater than 0 ");

        uint256 transactionId= transactions.length;
        transactions.push(Transaction({to:_to,value:msg.value,executive:false}));
        emit TransactionSubmitted(transactionId,msg.sender,_to,msg.value);
    }
    function confirmationTransaction(uint256 _transactionId) public {
        require(_transactionId<transactions.length,"invalid transactionid");
        require(isConfirmed[_transactionId][msg.sender],"Transaction is already confirmed by the owner");
        isConfirmed[_transactionId][msg.sender]=true;
        emit TransactionConfirmed(_transactionId);

    }

    

    function executeTransaction(uint _transactionId) public payable{
       require(_transactionId<transactions.length,"Invalid Transaction Id");
       require(!transactions[_transactionId].executive,"Transaction is already executed");
        (bool success,) =transactions[_transactionId].to.call{value: transactions[_transactionId].value}("");
         require(success,"Transaction Execution Failed");
         transactions[_transactionId].executive=true;
         emit TransactionExecuted(_transactionId);
    }

    function isTransactionConfirmed(uint _transactionId) internal view returns(bool){
         require(_transactionId<transactions.length,"Invalid Transaction Id");
         uint confimationCount;//initially zero


         for(uint i=0;i<owners.length;i++){
             if(isConfirmed[_transactionId][owners[i]]){
                 confimationCount++;
             }
         }
         return confimationCount>=numConfirmationsRequired;
    }
}