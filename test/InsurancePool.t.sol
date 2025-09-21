// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/InsurancePool.sol";

contract InsurancePoolTest is Test {
    InsurancePool public insurancePool;

    // Mock user address
    address public client = address(0x1);
    uint256 public projectId = 1;
    uint256 public projectValue = 2 ether;

    function setUp() public {
        insurancePool = new InsurancePool();
    }

    // Test if a client can successfully create a Silver (50%) insurance policy
    function testCreatePolicy() public {
        uint256 coverage = 50; // Silver tier
        
        // Calculate the expected premium based on the contract's logic:
        uint256 expectedPremium = (projectValue * coverage * 2) / 10000;

        // Give the client enough ETH to pay the premium
        vm.deal(client, expectedPremium);

        // Simulate the transaction coming from the client, with the premium attached
        vm.prank(client);
        uint256 returnedPremium = insurancePool.createPolicy{value: expectedPremium}(projectId, coverage, projectValue);
        
        // --- VERIFY THE RESULTS ---
        assertEq(returnedPremium, expectedPremium, "Returned premium is incorrect");

        // THIS IS THE CORRECTED LINE:
        InsurancePool.InsurancePolicy memory policy = insurancePool.getPolicy(projectId);
        assertEq(policy.coverage, coverage, "Policy coverage is incorrect");
        assertEq(policy.premium, expectedPremium, "Policy premium is incorrect");
        assertTrue(policy.isActive, "Policy should be active");

        assertEq(insurancePool.totalPool(), expectedPremium, "Total pool balance is incorrect");
    }
}