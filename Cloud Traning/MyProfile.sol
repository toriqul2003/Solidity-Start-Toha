// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

// একটা Profile Contract যেখানে:
// ✅ নাম store হবে
// ✅ বয়স store হবে  
// ✅ তুমি active কিনা
// ✅ নাম update করা যাবে
// ✅ বয়স update করা যাবে
// ✅ সব info একসাথে দেখা যাবে

contract MyProfile {
     string public name;
     uint public age;
     bool public active;

    constructor (string memory _name,uint _age,bool status){
        name = _name;
        age = _age;
        active = status;
    }
    function updateName (string memory _NewName)public {
        name = _NewName;
    }
    function updateAge (uint _NewAge) public {
        age = _NewAge;
    }
    function seeInfo ()public view returns(string memory,uint,bool){
        return (name,age,active);
    }
}