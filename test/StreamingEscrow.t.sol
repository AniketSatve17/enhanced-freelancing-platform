// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/StreamingEscrow.sol";

contract StreamingEscrowTest is Test {
    StreamingEscrow public escrow;
    
    // Mock user addresses for testing
    address public client = address(0x1);
    address public freelancer = address(0x2);

    function setUp() public {
        escrow = new StreamingEscrow();
    }

    function testCreateProjectAndReleaseMilestone() public {
        // --- Part 1: Test Project Creation ---

        // Define the milestone payments
        uint256[] memory milestoneAmounts = new uint256[](2);
        milestoneAmounts[0] = 0.5 ether;
        milestoneAmounts[1] = 1.0 ether;
        uint256 totalProjectValue = 1.5 ether;

        // Give the client enough Ether to fund the project
        vm.deal(client, totalProjectValue);

        // Simulate the transaction coming from the client
        vm.prank(client);
        uint256 projectId = escrow.createProjectWithMilestones{value: totalProjectValue}(freelancer, milestoneAmounts, 0);

        // Check that the project was created correctly
        StreamingEscrow.Project memory project = escrow.projects(projectId);
        assertEq(project.client, client);
        assertEq(project.freelancer, freelancer);
        assertEq(project.totalAmount, totalProjectValue);
        assertEq(escrow.projectCount(), 1);

        // --- Part 2: Test Milestone Release ---
        
        uint256 initialFreelancerBalance = freelancer.balance;

        // 1. Freelancer completes the first milestone
        vm.prank(freelancer);
        escrow.completeMilestone(projectId, 0);

        // 2. Client releases the payment for the first milestone
        vm.prank(client);
        escrow.releaseMilestonePayment(projectId, 0);

        // 3. Check if the freelancer received the correct payment
        uint256 expectedBalance = initialFreelancerBalance + milestoneAmounts[0];
        assertEq(freelancer.balance, expectedBalance, "Freelancer did not receive payment");
    }
}