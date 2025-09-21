// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract QualityVerification {

    struct QualityCheck {
        uint256 projectId;
        uint256 milestone;
        string deliverableHash;
        uint256 automatedScore; // 0-100
        bool humanReviewRequired;
        bool verified;
    }

    mapping(uint256 => QualityCheck) public qualityChecks;
    uint256 public nextCheckId = 1;

    event QualityCheckCreated(uint256 indexed checkId, uint256 projectId);
    event AutomatedScoreUpdated(uint256 indexed checkId, uint256 score);

    function createQualityCheck(uint256 _projectId, uint256 _milestone, string memory _deliverableHash) external returns (uint256) {
        uint256 checkId = nextCheckId++;
        qualityChecks[checkId] = QualityCheck({
            projectId: _projectId,
            milestone: _milestone,
            deliverableHash: _deliverableHash,
            automatedScore: 0,
            humanReviewRequired: false,
            verified: false
        });

        emit QualityCheckCreated(checkId, _projectId);
        return checkId;
    }

    function updateAutomatedScore(uint256 _checkId, uint256 _score) external {
        require(_score <= 100, "Invalid score");
        QualityCheck storage check = qualityChecks[_checkId];
        
        check.automatedScore = _score;
        check.humanReviewRequired = _score < 70;
        check.verified = _score >= 70;

        emit AutomatedScoreUpdated(_checkId, _score);
    }

    // --- NEW GETTER FUNCTION ADDED HERE ---
    function getCheck(uint256 _checkId) external view returns (QualityCheck memory) {
        return qualityChecks[_checkId];
    }
}