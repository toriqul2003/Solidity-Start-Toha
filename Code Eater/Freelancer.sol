// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {FreelancerPofile,jobListingInput,JobListing,employee} from "./Type/DataType.sol";

contract FreelanceOpen {
    address owner;
    uint connectFee;

    employee[] public employers;
    FreelancerPofile[ ] public freelancerProfiles;

    mapping (uint => address) public freelanceridToAddress;
    mapping (uint => address) public employeridToAddress;

    event registerProfile (uint indexed id, address indexed caller);

    error FreelancerOpen_IncorectFee (uint expectedFee, uint actualFee);

    constructor ( ) {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
    require(msg.sender == owner, "You Are Not Owner");
    _;
    }


    function registerEmployee (string memory _name) external {
        employers.push(employee ({
         name : _name,
         id : employers.length,
         inHaiard : true,
         wallet : msg.sender,
         jobListings : new JobListing[](0)
        }));
        employeridToAddress[employers.length] = msg.sender;
        emit registerProfile(employers.length, msg.sender);
    }

    function getTotalEmployee () external view returns (uint) {
        return employers.length;
    }

    function registerFreelancer (string memory _name,  uint _experienceYear) external  {
        
        freelancerProfiles.push(FreelancerPofile({
        name    : _name,
        ID : freelancerProfiles.length,
        isActive : true,
        experienceYear : _experienceYear,
        wallet : msg.sender
        }));
        freelanceridToAddress[freelancerProfiles.length] = msg.sender;

        emit registerProfile(freelancerProfiles.length, msg.sender);
    }

    function getFreelancerProfileNumber () external view returns (uint){
        return freelancerProfiles.length;
    }

    function getFreelancerProfiles () external view returns (FreelancerPofile[] memory){
        return freelancerProfiles;
    }

    function _getEmployerProfiles (uint employerID) internal view returns (employee storage){
        return employers[employerID];
    }

    function getNumberOfCreatedJobList (uint employerID) public  view returns (uint){
       return employers[employerID].jobListings.length;
    }


    function creatJobListing (uint employerID, jobListingInput memory _jobListingInputs) external payable {
            if (msg.value != _jobListingInputs.price){
                revert FreelancerOpen_IncorectFee (_jobListingInputs.price, msg.value);
            }
            employee storage employerProbile = _getEmployerProfiles(employerID);
            
            uint JobID = getNumberOfCreatedJobList(employerID);

            JobListing memory newJob = JobListing({
                id :JobID,
                title : _jobListingInputs.title,
                jobDiscription : _jobListingInputs.jobDiscription,
                dedlineTimestamp : _jobListingInputs.dedlineTimestamp,
                price : _jobListingInputs.price,
                isOpen : true,
                hasHierdFreelancer : false,
                hierdFrelancerID : 0,
                isPaid : false
            });

            employerProbile.jobListings.push(newJob);
           
        }

}