// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/*একটা Contract যেখানে:

✅ প্রতিটা Student এর:
   → নাম (string)
   → বয়স (uint)
   → pass হয়েছে কিনা (bool)

✅ Student add করা যাবে
✅ Student এর নাম দিয়ে বয়স পাওয়া যাবে
✅ মোট কতজন Student আছে দেখা যাবে
✅ সব Students এর নাম দেখা যাবে?*/

contract StudentID{
    struct student{
        string name;
        uint age;
        bool isPassed;
    }
    student[] public students;
    mapping (string => uint) public NameToAge;

    function addStudent(string memory _name, uint _age, bool _isPassed) public {
        students.push(student({
            name : _name,
            age  : _age,
            isPassed : _isPassed
        }));
        NameToAge[_name] = _age;
    } 
    
    function getStudentCount() public view returns (uint){
        return students.length;
    }

    function getAllNames() public view returns (string[] memory) {

        string[] memory names = new string[](students.length);

        for (uint i = 0; i < students.length; i++) {
             names[i] = students[i].name;
        }
        return names;
}
}