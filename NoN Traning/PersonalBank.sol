// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract personalBank{
    address public owner;
    string public bankName;
    uint public balance;

    constructor (string memory _bankName){
        owner = msg.sender;
        bankName= _bankName;
        balance = 0;
    }

    event Transaction (address from, address to, uint amount);

    modifier onlyOwner{
        require( msg.sender == owner,"You are not Owner");
        _;
    }

    function deposit (uint _amount, address _to) public onlyOwner{
        require(_amount > 0, "Should Add more Amount");
        balance += _amount;
        emit Transaction(msg.sender, _to, _amount);
    }

    function withdraw (uint _amount) public onlyOwner{
        require(_amount <= balance, "Incafisient Balance");
        balance -= _amount;
    }

    function getBalance () public view onlyOwner returns (uint){
        return balance;
    }
}