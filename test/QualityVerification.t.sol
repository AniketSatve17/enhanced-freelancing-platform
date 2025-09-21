// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/QualityVerification.sol";

contract QualityVerificationTest is Test {
    QualityVerification public qualityVerification;
    
    uint256 public projectId = 1;
    uint256 public milestone = 0;
    string public deliverableHash = "ipfs_hash_xyz";

    function setUp() public {
        qualityVerification = new QualityVerification();
    }

    function testCreateCheckAndUpdateScore() public {
        // Create a new quality check
        uint256 checkId = qualityVerification.createQualityCheck(projectId, milestone, deliverableHash);
        
        // --- Test 1: Update with a high score (should pass verification) ---
        qualityVerification.updateAutomatedScore(checkId, 95);

        QualityVerification.QualityCheck memory high_score_check = qualityVerification.getCheck(checkId);
        assertEq(high_score_check.automatedScore, 95, "Score should be 95");
        assertTrue(high_score_check.verified, "Should be verified with a high score");
        assertFalse(high_score_check.humanReviewRequired, "Should not need human review");

        // --- Test 2: Update with a low score (should fail verification and require review) ---
        qualityVerification.updateAutomatedScore(checkId, 60);

        QualityVerification.QualityCheck memory low_score_check = qualityVerification.getCheck(checkId);
        assertEq(low_score_check.automatedScore, 60, "Score should be 60");
        assertFalse(low_score_check.verified, "Should not be verified with a low score");
        assertTrue(low_score_check.humanReviewRequired, "Should need human review");
    }
}