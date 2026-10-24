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
    mapping (uint => uint) public employerBalances;

    event registerProfile (uint indexed id, address indexed caller);

    error IncorectFee (uint expectedFee, uint actualFee);
    error InvalidEmployerID (uint employerID , address caller);
    error InvalidFreelancerID (uint freelancerID , address caller);
    error InvalidJobID (uint jobID, uint employerID);
    error jobClosed (uint jobID);
    error NotEnoughBalance (uint JobPrice,uint haveBalance);
    error FreelancerIDNotMatchs (uint GivenID, uint ActualID);
    error alradyPaid (uint jobID);

    constructor ( ) {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "You Are Not Owner");
        _;
    }
    
    modifier onlyAuthorizedEmployee (uint employerID){
        address employer = employeridToAddress[employerID];

        if (msg.sender != employer || employer == address(0)){
            revert InvalidEmployerID (employerID, msg.sender);
        } 
         _;
    }
        modifier onlyAuthorizedFreenalcer (uint freelancerID){
        if (freelancerID >= getFreelancerProfileNumber() || freelanceridToAddress[freelancerID] == address(0)){
            revert InvalidFreelancerID (freelancerID, msg.sender);
        } 
         _;
    }
        modifier validatJobID (uint jobID,uint employerID){
        if (jobID >= createdJobNum(employerID)){
            revert InvalidJobID (jobID, employerID);
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

    function getFreelancerProfileNumber () public view returns (uint){
        return freelancerProfiles.length;
    }

    function getFreelancerProfiles () external view returns (FreelancerPofile[] memory){
        return freelancerProfiles;
    }

    function _getEmployerProfile (uint employerID) internal view returns (employee storage){
        return employers[employerID];
    }

    function createdJobNum (uint employerID) public view returns (uint) {
        return employers [employerID].jobListings.length;
    }

    function createJob (uint employerID, jobListingInput memory _JoblistingInput) external payable {
        if (msg.value != _JoblistingInput.price){
            revert IncorectFee(_JoblistingInput.price, msg.value);
        }
        employee storage employerProbile = _getEmployerProfile(employerID);
        uint JobID = createdJobNum (employerID);

        JobListing memory newJobListing = JobListing ({
             id :JobID,
             title :_JoblistingInput.title,
             jobDiscription :_JoblistingInput.jobDiscription,
             dedlineTimestamp : block.timestamp + _JoblistingInput.dedlineTimestamp,
             price : _JoblistingInput.price,
             isOpen : true,
             hasHierdFreelancer : false,
             hierdFrelancerID : 0,
             isPaid : false
        });
        employerBalances[employerID] = _JoblistingInput.price;
        employerProbile.jobListings.push(newJobListing);
        
    }

    function _getJob (uint employerID, uint jobID) internal view returns (JobListing storage){
        return employers[employerID].jobListings[jobID];
    }

    function _requerJob (JobListing memory job) internal pure {
        if (job.isOpen != true){
            revert jobClosed (job.id);
        }
    }
    function getJobList (uint employerID) external view returns (JobListing[ ] memory){
        return employers[employerID].jobListings;
    }

    function hireFreelancer (uint employerID, uint jobID, uint freelancerID) public 
    onlyAuthorizedEmployee(employerID) onlyAuthorizedFreenalcer(freelancerID)validatJobID (jobID,employerID)
    {
        JobListing storage job = _getJob (employerID, jobID);
        _requerJob (job);
        job.hierdFrelancerID = freelancerID;
        job.isOpen = false;
        job.hasHierdFreelancer= true;
    }

    function calculatePayment (uint amountToSend, uint jobDedlineTimestamp) internal view returns (uint) {
        if (block.timestamp >= jobDedlineTimestamp){
            return amountToSend;
        }
        uint delayCompletion = block.timestamp - jobDedlineTimestamp;
        uint delayInDays = (delayCompletion + 1 days -1 days) /1 days;
        uint diductionBps = delayInDays * LATE_PENALTY_BPS_PER_DAY;

        if (diductionBps > BPS_DOMINATOR){
            diductionBps = BPS_DOMINATOR;
        }
        uint diductionAmount = (amountToSend * diductionBps) / BPS_DOMINATOR;
        return amountToSend - diductionAmount;
    }

    function releasEscrowPayment (uint employerID, uint jobID, uint freelancerID) external 
    onlyAuthorizedEmployee(employerID) onlyAuthorizedFreenalcer(freelancerID)validatJobID (jobID,employerID)
    {
        JobListing storage job = _getJob (employerID, jobID);
        uint amountToSend = job.price;

        if (employerBalances[employerID] > amountToSend ){
            revert NotEnoughBalance (amountToSend, employerBalances[employerID]);
        }
        if (freelancerID != job.hierdFrelancerID){
            revert FreelancerIDNotMatchs (freelancerID, job.hierdFrelancerID);
        }
        if (job.isPaid == true){
            revert alradyPaid (jobID);
        }
        employerBalances[employerID] -= amountToSend;
        uint paymentAmount = calculatePayment(amountToSend, job.dedlineTimestamp);
    }

    }
