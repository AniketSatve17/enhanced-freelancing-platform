// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract InsurancePool {

    struct InsurancePolicy {
        uint256 coverage; // e.g., 25, 50, or 75
        uint256 premium;
        bool isActive;
    }

    struct Claim {
        uint256 projectId;
        address claimant;
        uint256 amount;
        string reason;
        bool resolved;
        bool approved;
    }

    mapping(uint256 => InsurancePolicy) public policies;
    mapping(uint256 => Claim) public claims;
    mapping(address => uint256) public stakes;
    uint256 public totalPool;
    uint256 public nextClaimId = 1;

    event PolicyCreated(uint256 indexed projectId, uint256 coverage);
    event ClaimSubmitted(uint256 indexed claimId, uint256 projectId);
    event ClaimResolved(uint256 indexed claimId, bool approved);

    function createPolicy(uint256 _projectId, uint256 _coverage, uint256 _projectValue) external payable returns (uint256 premium) {
        require(_coverage == 25 || _coverage == 50 || _coverage == 75, "Invalid coverage");
        premium = (_projectValue * _coverage * 2) / 10000; // 0.2% base rate of the covered amount
        require(msg.value >= premium, "Insufficient premium");

        policies[_projectId] = InsurancePolicy({
            coverage: _coverage,
            premium: premium,
            isActive: true
        });

        totalPool += premium;
        emit PolicyCreated(_projectId, _coverage);
        return premium;
    }

    function submitClaim(uint256 _projectId, uint256 _amount, string memory _reason) external returns (uint256) {
        require(policies[_projectId].isActive, "No active policy");
        uint256 claimId = nextClaimId++;

        claims[claimId] = Claim({
            projectId: _projectId,
            claimant: msg.sender,
            amount: _amount,
            reason: _reason,
            resolved: false,
            approved: false
        });

        emit ClaimSubmitted(claimId, _projectId);
        return claimId;
    }
}