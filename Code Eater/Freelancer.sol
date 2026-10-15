// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {FreelancerPofile} from "./Type/DataType.sol";

contract FreelanceOpen {
    address owner;
    uint connectFee;

    FreelancerPofile[ ] public freelancerProfiles;

    constructor ( ) {
        owner = msg.sender;
    }

    function register (string memory _name,  uint _experienceYear) external  {
        
        
        freelancerProfiles.push(FreelancerPofile({
        name    : _name,
        ID : freelancerProfiles.length,
        isActive : true,
        experienceYear : _experienceYear,
        wallet : msg.sender
        }));
    }

    function getFreelancerProfileNumber () external view returns (uint){
        return freelancerProfiles.length;
    }

    function getFreelancerProfiles () external view returns (FreelancerPofile[] memory){
        return freelancerProfiles;
    }

}