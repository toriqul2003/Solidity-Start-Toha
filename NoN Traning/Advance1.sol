// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Advance {
    function getContractBalance () public view returns (uint) {
        return address(ms).balance;
    }
}