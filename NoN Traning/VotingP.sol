// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract VotingSystem{
    uint public candidateCount;
    uint public voteEnding;
    address public owner;

    struct candidate{
        string name;
        uint VoteCount;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "Invalid Owner");
        _;
    }

    modifier voteActive{
        require(block.timestamp <= voteEnding, "Voting is not Active");
        _;
    }

    modifier voteEnded{
        require(block.timestamp >= voteEnding, "Voting is shil Active");
        _;
    }

    event CandidateAdded (address indexed AddedBy,string indexed name,uint indexed ID);
    event Voted (address indexed Voter,uint indexed ID);
    event Winner (string indexed name, uint indexed ID, uint indexed TotalVote);

    constructor (){
        owner = msg.sender;
        voteEnding = block.timestamp + 60 minutes;
    }

    mapping (uint => candidate) public candidates;
    mapping (address => bool) public hasVoted;

    function AddCandidate (string memory _name) public onlyOwner{
        candidateCount++;
        candidates[candidateCount]= candidate(_name,0);
        
        emit CandidateAdded (msg.sender,_name,candidateCount); 
    }

    function vote (uint CandidateID) public voteActive{
        require (!hasVoted[msg.sender],"Alrady Voted");
        require (CandidateID >0 && CandidateID <= candidateCount);

        hasVoted[msg.sender] = true;
        candidates[CandidateID].VoteCount++; 
        emit Voted(msg.sender, CandidateID);
    }

    function RemainingTime () public view returns (uint){
        return block.timestamp - voteEnding;
    }

}