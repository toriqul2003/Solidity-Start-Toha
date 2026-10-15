// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SecurityBank is ReentrancyGuard {
    mapping (address => uint) public Balance;

    function withdraw () public nonReentrant {
        uint amount = Balance[msg.sender];
        require(amount > 0, "Not Enough Balance");

        Balance[msg.sender] = 0;

        (bool sent, )= msg.sender.call{value : amount} ("");
        require(sent, "Failed"); 
    }
}