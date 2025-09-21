// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/DisputeJury.sol";

contract DisputeJuryTest is Test {
    DisputeJury public disputeJury;

    // Mock user addresses
    address public plaintiff = address(0x1);
    address public defendant = address(0x2);
    address public juror1 = address(0x3);
    address public juror2 = address(0x4);
    address public juror3 = address(0x5);
    
    uint256 public projectId = 1;

    function setUp() public {
        disputeJury = new DisputeJury();

        // Set up jurors with enough ETH to stake
        vm.deal(juror1, 0.1 ether);
        vm.deal(juror2, 0.1 ether);
        vm.deal(juror3, 0.1 ether);
    }

    function testFullDisputeLifecycle() public {
        // --- Part 1: Jurors stake to join ---
        vm.prank(juror1);
        disputeJury.becomeJuror{value: 0.01 ether}();
        vm.prank(juror2);
        disputeJury.becomeJuror{value: 0.01 ether}();
        vm.prank(juror3);
        disputeJury.becomeJuror{value: 0.01 ether}();

        // --- Part 2: Plaintiff creates a dispute ---
        vm.deal(plaintiff, 0.005 ether); // Give plaintiff the dispute fee
        vm.prank(plaintiff);
        uint256 disputeId = disputeJury.createDispute{value: 0.005 ether}(projectId, defendant, "Evidence hash");

        // --- Part 3: Jurors vote (2 vote for plaintiff, 1 against) ---
        vm.prank(juror1);
        disputeJury.vote(disputeId, true); // Vote for plaintiff
        vm.prank(juror2);
        disputeJury.vote(disputeId, true); // Vote for plaintiff
        vm.prank(juror3);
        disputeJury.vote(disputeId, false); // Vote against plaintiff

        // Check that votes were recorded correctly before resolving
        (uint256 votesFor, uint256 votesAgainst) = disputeJury.getDisputeVotes(disputeId);
        assertEq(votesFor, 2);
        assertEq(votesAgainst, 1);

        // --- Part 4: Fast-forward time and resolve the dispute ---
        vm.warp(block.timestamp + 25 hours);
        disputeJury.resolveDispute(disputeId);

        // --- VERIFY THE FINAL RULING ---
        // THIS IS THE CORRECTED SECTION:
        (bool resolved, bool ruling) = disputeJury.getDisputeStatus(disputeId);
        assertTrue(resolved, "Dispute should be resolved");
        assertTrue(ruling, "Ruling should favor the plaintiff");
    }
}