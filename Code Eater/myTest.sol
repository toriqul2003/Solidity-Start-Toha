// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {FreelancerPofile,employee,jobListingInput,JobListing} from "./DataType.sol";

contract FreelancerHire {
    address owner;
    uint constant public LATE_PENALTY_BPS_PER_DAY = 500;
    uint constant public BPS_DOMINATOR = 10000;

    FreelancerPofile [] public freelancers;
    employee [] public employers;

    mapping (uint => address) public employerIdToAddress;
    mapping (uint => address) public freelancerIdToAddress;
    mapping (uint => uint) public employerBalance;

    event Registerd (address indexed Caller,uint indexed ID);

    error UnothorizedOwner (address Caller,address AuthorizedOwner);
    error IncorrectJobPayment (uint sendedAmount,uint Price);
    error UnothorizedEmployer (address caller,uint employerID);
    error UnothorizedFreelancer (address caller, uint freelanerID);
    error InValidJobID (uint caller, uint JobID);
    error JobClosed (uint jobID);
    error InValidFreelancerID (uint freelanerID, uint ActualID);
    error AlradyPaid (uint jobID);
    error notEnoughBalance (uint haveBalance,uint Price);
    error paymentFailed (address to, uint Amount);

    constructor (){
        owner = msg.sender;
    }

    modifier OnlyOwner {
        if (owner != msg.sender){
            revert UnothorizedOwner (msg.sender, owner);
        }_;
    }
        modifier OnlyAuthorizedEmployer (uint employerID) {
        if (msg.sender != employerIdToAddress[employerID]){
            revert UnothorizedEmployer (msg.sender,employerID);
        }_;
    }
        modifier OnlyAuthorizedFreelaner (uint freelancerID) {
        if (freelancerID > freelancers.length){
            revert UnothorizedFreelancer(msg.sender,freelancerID);
        }_;
    }
        modifier ValidetJobID (uint employerID,uint jobID) {
        if (jobID > getJobNum (employerID)){
            revert InValidJobID (employerID,jobID);
        }_;
    }

    function regEmployer (string memory _name) external {
        employee memory employerProfile = employee ({
        name : _name,
        id : employers.length,
        hasHaiard : false,
        wallet:msg.sender,
        jobListings : new JobListing[](0)
        });
        employers.push(employerProfile);
        employerIdToAddress[employers.length] = msg.sender;
        emit Registerd(msg.sender, employers.length);
    }

    function regFreelancer(string memory _name, uint _experienceYear) external {
        FreelancerPofile memory _freelancerProfile = FreelancerPofile ({
        name : _name,
        ID : freelancers.length,
        isActive : true,
        experienceYear : _experienceYear,
        wallet :msg.sender
        });
        freelancers.push(_freelancerProfile);
        freelancerIdToAddress[freelancers.length] = msg.sender;
        emit Registerd(msg.sender, freelancers.length);
    }

    function getJobNum (uint employerID) public view returns (uint) {
        return employers[employerID].jobListings.length;
    }
    
    function createJobListing (uint employerID, jobListingInput memory _jobInput) external payable 
     OnlyAuthorizedEmployer (employerID){  
        if (msg.value != _jobInput.price){
            revert IncorrectJobPayment (msg.value, _jobInput.price);
        }
        
        uint jobID = getJobNum (employerID);
        JobListing memory newjob = JobListing ({
         id : jobID,
         title : _jobInput.title,
         jobDiscription : _jobInput.jobDiscription,
         dedlineTimestamp : block.timestamp + _jobInput.dedlineTimestamp,
         price : _jobInput.price,
         isOpen : true,
         hasHierdFreelancer : false,
         hierdFrelancerID :  0,
         isPaid : false
        });
        employerBalance[employerID] = msg.value;
        employers[employerID].jobListings.push(newjob);
    } 

    function _getJob (uint employerID, uint jobID) internal view returns (JobListing storage) {
       return employers[employerID].jobListings[jobID];
    }

    function _requrJob (JobListing memory job) internal pure  {
        if (job.isOpen == false){
            revert JobClosed (job.id);
        }
    }


    function hireFreelancer (uint employerID,uint freelancerID,uint jobID) external 
     OnlyAuthorizedEmployer (employerID)OnlyAuthorizedFreelaner (freelancerID)ValidetJobID (employerID,jobID)
    {
    JobListing storage job =  _getJob (employerID,jobID);
    _requrJob (job);
    job.hierdFrelancerID = freelancerID;
    job.hasHierdFreelancer = true;
    job.id = jobID;
    }

    function _calculateDelay (uint amountToSend,uint dedline) internal view returns (uint){
        if (block.timestamp < dedline){
            return amountToSend;
        }
        uint DelayCalculate = block.timestamp - dedline;
        uint delayInDays = (DelayCalculate + 1 days - 1)/1 days;
        uint diductionBps = delayInDays * LATE_PENALTY_BPS_PER_DAY;
        if (diductionBps > BPS_DOMINATOR){
            diductionBps = BPS_DOMINATOR;
        }
        uint diductionAmount = (amountToSend * diductionBps)/ BPS_DOMINATOR;
        return amountToSend - diductionAmount;
    }

    function _sendpaymentToFreelacer (address freelancer,uint amountToSend) internal {
        (bool success,)= freelancer.call{value: amountToSend}("");
        if (success == false){
            revert paymentFailed (freelancer,amountToSend);
        }
    } 

    function relesePaymet (uint employerID,uint freelancerID,uint jobID) external 
    OnlyAuthorizedEmployer (employerID)OnlyAuthorizedFreelaner (freelancerID)ValidetJobID (employerID,jobID)
    {
        JobListing storage job =  _getJob (employerID,jobID);
        uint amountToSend = job.price;
        if (amountToSend > employerBalance[employerID]){
            revert notEnoughBalance(employerBalance[employerID],amountToSend);
        }
        if (freelancerID != job.hierdFrelancerID){
            revert InValidFreelancerID (freelancerID, job.hierdFrelancerID);
        }
        if (job.isPaid == true){
            revert AlradyPaid (jobID);
        }
        employerBalance[employerID] -= amountToSend;
        uint paymentAmount = _calculateDelay (amountToSend,job.dedlineTimestamp);
        _sendpaymentToFreelacer (freelancerIdToAddress[freelancerID],paymentAmount);
    }

    function withdrowAmount (uint employerID,uint amount) external OnlyAuthorizedEmployer(employerID) {
        if (amount > employerBalance[employerID]){
            revert notEnoughBalance (employerBalance[employerID],amount);
        }
        employerBalance[employerID] -= amount ;
        (bool success,)= employerIdToAddress[employerID].call{value: amount}("");
        if (success == false){
            revert paymentFailed (employerIdToAddress[employerID],amount);
        }
    }
    } 
