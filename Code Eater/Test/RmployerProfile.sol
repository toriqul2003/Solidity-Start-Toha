// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract Employers {
    address owner;

    struct employee {
        string name;
        uint id;
        bool inHaiard;
        address wallet;
    }

    employee[] public employers;
    mapping (uint => address) public idToAddress;

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You Are Not Owner");
        _;
    }

    function registerEmployee (string memory _name, address _wallet) external {
        employers.push(employee ({
         name : _name,
         id : employers.length,
         inHaiard : true,
         wallet : _wallet
        }));
        idToAddress[employers.length] = msg.sender;
    }

    function getTotalEmployee () external view returns (uint) {
        return employers.length;
    }

}