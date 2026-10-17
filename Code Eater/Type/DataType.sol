// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

struct FreelancerPofile {
    string name;
    uint ID;
    bool isActive;
    uint experienceYear;
    address wallet;
}

struct employee {
    string name;
    uint id;
    bool inHaiard;
    address wallet;
    JobListing [ ] jobListings;
    }

struct jobListingInput {
    string title;
    string jobDiscription;
    uint dedlineTimestamp;
    uint price;
}

struct JobListing {
    uint id;
    string title;
    string jobDiscription;
    uint dedlineTimestamp;
    uint price; 
    bool isOpen;
    bool hasHierdFreelancer;
    uint hierdFrelancerID;
    bool isPaid;
}

