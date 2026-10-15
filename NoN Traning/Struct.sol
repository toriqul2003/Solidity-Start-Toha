// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Struct {
    // struct NID {
    //     string Name;
    //     string Father;
    //     string Mother;
    //     uint Age;
    //     string Blood;
    //     address wallet;
    // }

    // mapping (address => NID) public Nids;

    // function setNID (string memory _name,string memory _father, string memory _mother, uint _age, string memory _blood) public {
    //     Nids[msg.sender] = NID
    //     ({
    //     Name:   _name,
    //     Father: _father,
    //     Mother: _mother,
    //     Age:    _age,
    //     Blood:  _blood,
    //     wallet: msg.sender
    //     });
    // }

    struct product{
        string name;
        uint price;
        bool stock;
    }
    
    product[] public Products;

    function AddProduct (string memory _name, uint _price, bool _Stock) public {
        Products.push(product({
            name : _name,
            price: _price,
            stock: _Stock
        }));
    }
    function getProduct (uint _index) public view returns (product memory){
            return Products[_index];
    }

}