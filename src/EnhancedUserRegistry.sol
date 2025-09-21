// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Import the interfaces of the other contracts
import "./GasSponsorship.sol";
import "./ReputationNFT.sol";

contract EnhancedUserRegistry {
    // --- STATE VARIABLES ---
    GasSponsorship public gasSponsorshipContract;
    ReputationNFT public reputationNFTContract;

    // Define the deposit split for clarity and easy management
    uint256 public constant DEPOSIT_REFUNDABLE = 0.02 ether;
    uint256 public constant DEPOSIT_GAS_POOL = 0.015 ether;
    uint256 public constant TOTAL_DEPOSIT = DEPOSIT_REFUNDABLE + DEPOSIT_GAS_POOL;

    struct User {
        address wallet;
        string name;
        uint256 reputation;
        bool isActive;
        uint256 depositAmount; // Now only stores the refundable part
        uint256[] completedTrials;
        uint256 insuranceStake;
    }

    mapping(address => User) public users;
    mapping(address => bool) public isRegistered;

    event UserRegistered(address indexed user);
    event TrialCompleted(address indexed user, uint256 tokenId, uint256 score);

    // The constructor now takes the addresses of BOTH modular contracts
    constructor(address _gasSponsorshipAddress, address _reputationNFTAddress) {
        gasSponsorshipContract = GasSponsorship(_gasSponsorshipAddress);
        reputationNFTContract = ReputationNFT(_reputationNFTAddress);
    }

    function registerUser(string memory _name) external payable {
        // Check if the user sent the exact total deposit amount
        require(msg.value == TOTAL_DEPOSIT, "Incorrect deposit amount");
        require(!isRegistered[msg.sender], "Already registered");

        // --- DEPOSIT SPLIT LOGIC ---
        // Send the gas pool portion of the deposit to the GasSponsorship contract
        gasSponsorshipContract.addDeposit{value: DEPOSIT_GAS_POOL}();

        // Store the user's data with the refundable portion of the deposit
        users[msg.sender] = User({
            wallet: msg.sender,
            name: _name,
            reputation: 100,
            isActive: true,
            depositAmount: DEPOSIT_REFUNDABLE, // Only store the refundable part
            completedTrials: new uint256[](0),
            insuranceStake: 0
        });

        isRegistered[msg.sender] = true;
        emit UserRegistered(msg.sender);
    }

    function completeTrialBadge(address _freelancer, string memory _skillArea, uint256 _score) external returns (uint256) {
        require(isRegistered[_freelancer], "Freelancer not registered");
        
        uint256 tokenId = reputationNFTContract.mintCredential(_freelancer, _skillArea, _score, msg.sender);

        users[_freelancer].completedTrials.push(tokenId);
        users[_freelancer].reputation += _score / 10;
        
        emit TrialCompleted(_freelancer, tokenId, _score);
        return tokenId;
    }
}