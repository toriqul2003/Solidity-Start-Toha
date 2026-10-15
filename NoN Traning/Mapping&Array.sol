// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MappingArray {
    mapping (address => uint) public balences;
    address [] public users;

    function deposit (uint Value) public payable {
        if (balences[msg.sender]==0){
            users.push(msg.sender);
        }
        balences[msg.sender] += Value;
    }

}