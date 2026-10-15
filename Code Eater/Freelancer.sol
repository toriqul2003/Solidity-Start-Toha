// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {FreelancerPofile,jobListingInput} from "./Type/DataType.sol";

contract FreelanceOpen {
    address owner;
    uint connectFee;

     struct employee {
        string name;
        uint id;
        bool inHaiard;
        address wallet;
    }

    employee[] public employers;
    FreelancerPofile[ ] public freelancerProfiles;

    mapping (uint => address) public idToAddress;

    event registerProfile (uint indexed id, address indexed caller);

    error FreelancerOpen_IncorectFee (uint expectedFee, uint actualFee);

    constructor ( ) {
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
        emit registerProfile(employers.length, msg.sender);
    }

    function getTotalEmployee () external view returns (uint) {
        return employers.length;
    }

    function register (string memory _name,  uint _experienceYear) external  {
        
        
        freelancerProfiles.push(FreelancerPofile({
        name    : _name,
        ID : freelancerProfiles.length,
        isActive : true,
        experienceYear : _experienceYear,
        wallet : msg.sender
        }));
        idToAddress[freelancerProfiles.length] = msg.sender;

        emit registerProfile(freelancerProfiles.length, msg.sender);
    }

    function getFreelancerProfileNumber () external view returns (uint){
        return freelancerProfiles.length;
    }

    function getFreelancerProfiles () external view returns (FreelancerPofile[] memory){
        return freelancerProfiles;
    }

    function creatJobListing (
        uint employerID, 
        jobListingInput memory jobListingInputs
        ) external  payable  {
            if (msg.value != jobListingInputs.price){
                revert FreelancerOpen_IncorectFee (jobListingInputs.price, msg.value);
            }
        }

}