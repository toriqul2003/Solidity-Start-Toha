// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Wallert{

    mapping (address => uint) public balances;

    function diposit (uint _amount) public {
        require(_amount > 0, "Not Valid Amount");
        balances[msg.sender] = _amount;
    }

    function withdrow (uint _amount) public {
        require(_amount > 0, "Not Valid Amount");
        balances[msg.sender] -=_amount;
    }

    function getBalance (address user) public view returns (uint){
        return balances[user];
    }
}