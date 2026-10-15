// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract A {
    string name;
    uint age;

    constructor (string memory _name, uint _age){
        name = _name;
        age = _age;
    }

    function fun1 () public pure virtual returns (string memory){
        return "Hello Moto";
    }
}

contract B is A {
    constructor (string memory _name, uint _age) A (name, age){
       
    }

    function fun1 () public pure override  returns (string memory){
        return "Hello Toha";
    }
}