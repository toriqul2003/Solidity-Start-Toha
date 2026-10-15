// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract TToken{
    string public name;
    string public symbol;
    uint public totalSupply;
    uint public decimals = 18;
    address public owner;

    mapping (address => uint) public Balances;
    mapping (address => mapping (address => uint)) public Allow;

    event transfar (address indexed from, address indexed to, uint value);
    event allowence (address indexed owner, address indexed spender, uint value);

    constructor (string memory _name, string memory _symbol, uint _totalSupply) {
            name = _name;
            symbol = _symbol;
            totalSupply = _totalSupply * 10 **decimals;
            Balances[msg.sender] = totalSupply;
            owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner,"Only Owner can Call");
        _;
    }

    function Transfar (address _to, uint _value) public onlyOwner returns (bool){
        require(_to != address(0), "Not Valid Address");
        require(Balances[msg.sender] >= _value, "Not Enough Balance");

        Balances[msg.sender] -= _value;
        Balances[_to] += _value;
         
         emit transfar(msg.sender, _to, _value);
         return true;
    }

    function FundAllow (address _spender, uint _value) public onlyOwner returns (bool){
        require(_spender != address(0), "Not Valid Address");
        Allow[msg.sender][_spender] = _value;
        emit allowence(msg.sender, _spender, _value);
        return true;
    }

    function TransfarFrom (address _from, address _to, uint _value) public returns (bool){
            require(_from != address(0) && _to != address (0), "Not valid Address");
            require(Balances[_from] >= _value, "Not Enough Balance");

            Balances[_from] -= _value;
            Balances[_to] += _value;

            emit transfar(_from, _to, _value);

            return true;
    }

    function getBalance () public view returns (uint){
        return Balances[msg.sender];
    }

}