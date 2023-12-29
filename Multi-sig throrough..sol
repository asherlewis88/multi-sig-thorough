// SPDX-License-Identifier: GFDL-1.3-or-later
pragma solidity ^0.8.9;

contract MultiSigThorough{
    // State variables
    address[] public owners; // The owners of the contract
    uint public transactionCount; // The total number of transactions
    uint public required; // The number of required confirmations

    // Data structures
    struct Transaction {
        address payable destination; // The destination address of the transaction
        uint value; // The value of the transaction in wei
        bool executed; // A flag indicating if the transaction has been executed
        bytes data; // The call data of the transaction
    }

    mapping(uint => Transaction) public transactions; // A mapping from transaction IDs to transactions
    mapping(uint => mapping(address => bool)) public confirmations; // A mapping from transaction IDs to owner addresses to confirmation statuses

    // Constructor
    constructor(address[] memory _owners, uint _confirmations) {
        require(_owners.length > 0, "No owners provided");
        require(_confirmations > 0, "No confirmations required");
        require(_confirmations <= _owners.length, "Too many confirmations required");
        owners = _owners;
        required = _confirmations;
    }
   
    // Receive function
    receive() payable external {
        // This function allows the contract to receive funds
    }

    // Add transaction function
    function addTransaction(address payable destination, uint value, bytes calldata data) public returns(uint) {
        require(isOwner(msg.sender), "Only owners can add transactions");
        transactions[transactionCount] = Transaction(destination, value, false, data);
        transactionCount += 1;
        return transactionCount - 1;
    }

    // Confirm transaction function
    function confirmTransaction(uint transactionId) public {
        require(isOwner(msg.sender), "Only owners can confirm transactions");
        require(transactionId < transactionCount, "Invalid transaction ID");
        require(!confirmations[transactionId][msg.sender], "Transaction already confirmed by sender");
        confirmations[transactionId][msg.sender] = true;
        if (isConfirmed(transactionId)) {
            executeTransaction(transactionId);
        }
    }

    // Execute transaction function
    function executeTransaction(uint transactionId) public {
        require(isConfirmed(transactionId), "Transaction not confirmed");
        Transaction storage txData = transactions[transactionId];
        require(!txData.executed, "Transaction already executed");
        (bool success, ) = txData.destination.call{value: txData.value}(txData.data);
        require(success, "Transaction failed");
        txData.executed = true;
    }

    // Check confirmation function
    function isConfirmed(uint transactionId) public view returns(bool) {
        return getConfirmationsCount(transactionId) >= required;
    }

    // Count confirmations function
    function getConfirmationsCount(uint transactionId) public view returns(uint) {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
           if (confirmations[transactionId][owners[i]]) {
                count++;
            }
        }
        return count;
    }

    // Check owner function
    function isOwner(address addr) private view returns(bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == addr) {
                return true;
            }
        }
        return false;
    }
}
 /**
   * @title MultiSig
   * @dev thoroughVersion of MultiSig for increased security
   * @custom:dev-run-script Multi-sig throrough..sol
   */ contract MultiSig {} 