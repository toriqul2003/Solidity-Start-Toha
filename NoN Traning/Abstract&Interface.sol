// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// abstract contract Man {
//     string public Name;
//     uint public Age;

//     function setName(string memory _name) public virtual;
//     function setAge(uint _age) public virtual;
// }

// contract Toha is Man {
//     function setName(string memory _name) public override {
//         Name = _name;
//     }

//     function setAge(uint _age) public override {
//         Age = _age;
//     }
// }

interface Itoken {
    function Name (string memory _Name) external returns (string memory) ;
    event setNameAS (address indexed setBY,string indexed setName);    
}

contract TCoin is Itoken {
    function Name (string memory _Name) external override returns (string memory) {
        
        emit setNameAS(msg.sender, _Name);
        return _Name;
    }
}

