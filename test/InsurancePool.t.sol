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
        // (projectValue * coverage * 0.2%) / 100 = (2e18 * 50 * 2) / 10000 = 0.02 ETH
        uint256 expectedPremium = (projectValue * coverage * 2) / 10000;

        // Give the client enough ETH to pay the premium
        vm.deal(client, expectedPremium);

        // Simulate the transaction coming from the client, with the premium attached
        vm.prank(client);
        uint256 returnedPremium = insurancePool.createPolicy{value: expectedPremium}(projectId, coverage, projectValue);

        // --- VERIFY THE RESULTS ---
        
        // 1. Check if the returned premium is correct
        assertEq(returnedPremium, expectedPremium, "Returned premium is incorrect");

        // 2. Check if the policy was saved with the correct details
        InsurancePool.InsurancePolicy memory policy = insurancePool.policies(projectId);
        assertEq(policy.coverage, coverage, "Policy coverage is incorrect");
        assertEq(policy.premium, expectedPremium, "Policy premium is incorrect");
        assertTrue(policy.isActive, "Policy should be active");

        // 3. Check if the total pool balance increased correctly
        assertEq(insurancePool.totalPool(), expectedPremium, "Total pool balance is incorrect");
    }
}