// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Mapping {
    mapping (address => uint) public balances;

    function setValue (uint _value)public{
        balances[msg.sender]=_value;
    }
    function getValue (address _user)public view returns (uint){
        return balances[_user];
    }
    function updateValue (uint _value)public {
        balances[msg.sender] += _value;
    }
    function deleteValue()public {
        delete balances[msg.sender];
    }
}