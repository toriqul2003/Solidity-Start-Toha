// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Array {
    // 2 Type of Array we have Fixd Size Array and Dynamic Array 
    // string [10] public student; //  Fixed
    string[] public students ; //  Dynamic 
    
    // Push Methord it add in the last 
    function Push (string memory _name) public {
        students.push(_name);
    }

    // Find Index Value
    function IndexValue (uint _index) public view returns(string memory){
        return students[_index];

    }
    
    function update (uint _index, string memory _name) public {
        students[_index] = _name;
    }

    function TotalElement () public view returns (uint){
        return students.length;
    }
    
    // pop Use to Delete Eliment From Last
    function pop () public {
        students.pop();
    }
}