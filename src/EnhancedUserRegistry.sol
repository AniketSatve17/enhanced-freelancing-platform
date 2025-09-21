// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EnhancedUserRegistry is ERC721 {

    struct User {
        address wallet;
        string name;
        uint256 reputation;
        bool isActive;
        uint256 depositAmount;
        uint256[] completedTrials;
        uint256 insuranceStake;
    }

    struct TrialBadge {
        string skillArea;
        uint256 score;
        address issuer;
        uint256 timestamp;
        bool verified;
    }

    mapping(address => User) public users;
    mapping(address => bool) public isRegistered;
    mapping(uint256 => TrialBadge) public trialBadges;
    
    uint256 public nextTrialId = 1;

    event UserRegistered(address indexed user, bool isFreelancer);
    event TrialCompleted(address indexed user, uint256 trialId, uint256 score);

    constructor() ERC721("Freelance Credentials", "FLCRED") {}

    function registerUser(string memory _name, bool _isFreelancer) external payable {
        require(msg.value >= 0.035 ether, "Insufficient deposit");
        require(!isRegistered[msg.sender], "Already registered");

        users[msg.sender] = User({
            wallet: msg.sender,
            name: _name,
            reputation: 100,
            isActive: true,
            depositAmount: msg.value,
            completedTrials: new uint256[](0),
            insuranceStake: 0
        });

        isRegistered[msg.sender] = true;
        emit UserRegistered(msg.sender, _isFreelancer);
    }

    function completeTrialBadge(address _freelancer, string memory _skillArea, uint256 _score) external returns (uint256) {
        require(isRegistered[_freelancer], "Freelancer not registered");
        uint256 trialId = nextTrialId++;
        
        trialBadges[trialId] = TrialBadge({
            skillArea: _skillArea,
            score: _score,
            issuer: msg.sender,
            timestamp: block.timestamp,
            verified: true
        });

        users[_freelancer].completedTrials.push(trialId);
        users[_freelancer].reputation += _score / 10;
        
        _mint(_freelancer, trialId);
        emit TrialCompleted(_freelancer, trialId, _score);
        return trialId;
    }
}