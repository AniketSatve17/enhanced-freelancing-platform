// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract DisputeJury {

    struct Dispute {
        uint256 projectId;
        address plaintiff;
        address defendant;
        string evidence;
        uint256 stakeAmount;
        mapping(address => bool) hasVoted;
        uint256 votesFor;
        uint256 votesAgainst;
        bool resolved;
        bool ruling; // true = favor plaintiff
        uint256 createdAt;
    }

    mapping(uint256 => Dispute) public disputes;
    mapping(address => bool) public isJuror;
    mapping(address => uint256) public jurorStakes;
    
    uint256 public nextDisputeId = 1;
    uint256 public constant JUROR_STAKE = 0.01 ether;
    uint256 public constant VOTING_PERIOD = 24 hours;

    event DisputeCreated(uint256 indexed disputeId, uint256 projectId);
    event VoteCast(uint256 indexed disputeId, address juror);
    event DisputeResolved(uint256 indexed disputeId, bool ruling);

    function becomeJuror() external payable {
        require(msg.value >= JUROR_STAKE, "Insufficient stake");
        require(!isJuror[msg.sender], "Already a juror");

        isJuror[msg.sender] = true;
        jurorStakes[msg.sender] = msg.value;
    }

    function createDispute(uint256 _projectId, address _defendant, string memory _evidence) external payable returns (uint256) {
        require(msg.value >= 0.005 ether, "Dispute fee required");
        uint256 disputeId = nextDisputeId++;
        Dispute storage dispute = disputes[disputeId];

        dispute.projectId = _projectId;
        dispute.plaintiff = msg.sender;
        dispute.defendant = _defendant;
        dispute.evidence = _evidence;
        dispute.stakeAmount = msg.value;
        dispute.createdAt = block.timestamp;

        emit DisputeCreated(disputeId, _projectId);
        return disputeId;
    }

    function vote(uint256 _disputeId, bool _favorPlaintiff) external {
        require(isJuror[msg.sender], "Not a juror");
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Dispute already resolved");
        require(!dispute.hasVoted[msg.sender], "Already voted");
        require(block.timestamp <= dispute.createdAt + VOTING_PERIOD, "Voting period ended");

        dispute.hasVoted[msg.sender] = true;
        if (_favorPlaintiff) {
            dispute.votesFor++;
        } else {
            dispute.votesAgainst++;
        }
        emit VoteCast(_disputeId, msg.sender);
    }

    function resolveDispute(uint256 _disputeId) external {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Already resolved");
        require(block.timestamp > dispute.createdAt + VOTING_PERIOD, "Voting still active");

        dispute.resolved = true;
        dispute.ruling = dispute.votesFor > dispute.votesAgainst;
        emit DisputeResolved(_disputeId, dispute.ruling);
    }

    // Because the Dispute struct contains a mapping, we can't return the whole thing.
    // Instead, we create specific getters for the data we need to check.
    
    function getDisputeVotes(uint256 _disputeId) external view returns (uint256 votesFor, uint256 votesAgainst) {
        Dispute storage dispute = disputes[_disputeId];
        return (dispute.votesFor, dispute.votesAgainst);
    }

    function getDisputeStatus(uint256 _disputeId) external view returns (bool resolved, bool ruling) {
        Dispute storage dispute = disputes[_disputeId];
        return (dispute.resolved, dispute.ruling);
    }
}