// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {FreelancerPofile,jobListingInput,JobListing,employee} from "./DataType.sol";

contract FreelanceOpen {
    uint constant public LATE_PENALTY_BPS_PER_DAY = 500;
    uint constant public BPS_DOMINATOR = 10000;
    address owner;
    uint connectFee;

    employee[] public employers;
    FreelancerPofile[ ] public freelancerProfiles;

    mapping (uint => address) public freelanceridToAddress;
    mapping (uint => address) public employeridToAddress;
    mapping (uint => uint) public employerBalance;

    event registerProfile (uint indexed id, address indexed caller);

    error IncorectFee (uint expectedFee, uint actualFee);
    error JobClosed (uint JobID);
    error UnothorizedEmployer (address caller, uint employerID);
    error IncorectFrelancerID (address caller, uint frelancerID);
    error IncorectJobID (uint employerID, uint JobID);
    error NotEnoughBalance (uint expectedBalance,uint haveBalance);
    error IncorrectFreelancerID (uint ProvidedID, uint ActualID);
    error AlradyPaid (uint JobID);
    error paymentFailed (address freelancer, uint amount);
    error withdrowFailed (address employerAddress, uint amount);

    constructor ( ) {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You Are Not Owner");
    _;
    }
    
    modifier onlyAuthorizedEmployee (uint employerID){
        address employer = employeridToAddress[employerID];
        if (msg.sender != employer && employer == address(0)){
            revert UnothorizedEmployer(msg.sender, employerID);
        }
        _;
    }

    modifier onlyAuthorizedFreelancer (uint freelancerID) {
        if (freelancerID >= getTotalFreelancer () || freelanceridToAddress[freelancerID] == address(0)){
            revert IncorectFrelancerID (msg.sender, freelancerID);
        }
        _;
    }
    modifier validatJobID (uint employerID,uint JobID) {
        if (JobID >= getNumberOfCreatedJobList(employerID)){
            revert IncorectJobID (employerID,JobID);
        }
        _;
    }
    
    function registerEmployee (string memory _name) external {
        employers.push(employee ({
         name : _name,
         id : employers.length,
         hasHaiard : true,
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

    function getTotalFreelancer () public  view returns (uint){
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


    function creatJobListing (uint employerID, jobListingInput memory _jobListingInputs) external payable
    onlyAuthorizedEmployee (employerID) 
    {
            if (msg.value != _jobListingInputs.price){
                revert IncorectFee (_jobListingInputs.price, msg.value);
            }

            employee storage employerProbile = _getEmployerProfiles(employerID);
            
            uint JobID = getNumberOfCreatedJobList(employerID);

            JobListing memory newJob = JobListing({
                id :JobID,
                title : _jobListingInputs.title,
                jobDiscription : _jobListingInputs.jobDiscription,
                dedlineTimestamp : block.timestamp + _jobListingInputs.dedlineTimestamp,
                price : _jobListingInputs.price,
                isOpen : true,
                hasHierdFreelancer : false,
                hierdFrelancerID : 0,
                isPaid : false
            });
            employerBalance[employerID] += _jobListingInputs.price;
            employerProbile.jobListings.push(newJob);
           
    }

        function _getJob (uint employerID, uint JobID) internal view returns (JobListing storage) {
            return employers[employerID].jobListings[JobID];
        }

        function _requerJob (JobListing memory job) internal pure {
            if (job.isOpen != true){
                revert JobClosed (job.id);
            }
        }

        function getJobList (uint employerID) external view returns (JobListing[] memory){
            return employers[employerID].jobListings;
        }

        function hireFreelancer (uint employerID, uint freelancerID, uint JobID) public 
        onlyAuthorizedEmployee (employerID) onlyAuthorizedFreelancer (freelancerID) validatJobID (employerID,JobID)
        {

            JobListing storage job = _getJob(employerID, JobID);
            _requerJob (job);
            job.hierdFrelancerID = freelancerID;
            job.isOpen = false;
            job.hasHierdFreelancer= true;
        }

        function _calculatePament (uint amountToSend,uint jobDedline)internal view returns(uint){
            if (block.timestamp <= jobDedline){
             return amountToSend;
            }
            uint delayCompletion = block.timestamp - jobDedline;

            uint delayInDays = (delayCompletion + 1 days -1) /1 days; 

            uint diductionBps = delayInDays * LATE_PENALTY_BPS_PER_DAY;

            if (diductionBps > BPS_DOMINATOR){
                diductionBps = BPS_DOMINATOR;
            }

            uint diductionAmount = (amountToSend * diductionBps) / BPS_DOMINATOR;
            return amountToSend - diductionAmount;
        }

        function _sendPaymentToFreelancer (address freelancer, uint amountToSend) internal {
            (bool success,)= freelancer.call{value:amountToSend}("");
            if (success == false){
                revert paymentFailed (freelancer,amountToSend);
            }
        }

        function releasEscrowPyment (uint employerID, uint freelancerID, uint JobID) external 
        onlyAuthorizedEmployee (employerID) onlyAuthorizedFreelancer (freelancerID) validatJobID (employerID,JobID)
        {
            JobListing storage job = _getJob(employerID, JobID);
            uint amountToSend = job.price;

            if (job.price > employerBalance[employerID]){
                revert NotEnoughBalance (job.price,employerBalance[employerID]);
            }

            if (freelancerID != job.hierdFrelancerID){
                revert IncorrectFreelancerID (freelancerID, job.hierdFrelancerID);
            }

            if (job.isPaid == true){
                revert AlradyPaid (JobID);
            }
            job.isPaid = true;
            employerBalance[employerID] -= amountToSend; 
            uint pamentAmount = _calculatePament(amountToSend,job.dedlineTimestamp);
            _sendPaymentToFreelancer (freelanceridToAddress[freelancerID],pamentAmount);
        }

        function changeOwner (address newOwner) external onlyOwner{
            owner = newOwner;
        }

        function withdrowAmount (uint employerID,uint amount) external onlyAuthorizedEmployee (employerID) {
            if (employerBalance[employerID] < amount){
                revert NotEnoughBalance (amount, employerBalance[employerID]);
            }
            employerBalance[employerID] -= amount;
            (bool success,) = employeridToAddress[employerID].call{value:amount}("");
            if (success == false){
                revert withdrowFailed (employeridToAddress[employerID],amount);
            }
        }





}