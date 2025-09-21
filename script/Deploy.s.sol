// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/GasSponsorship.sol";
import "../src/ReputationNFT.sol";
import "../src/EnhancedUserRegistry.sol";
import "../src/StreamingEscrow.sol";
import "../src/InsurancePool.sol";
import "../src/DisputeJury.sol";
import "../src/QualityVerification.sol";

contract DeployContracts is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy standalone contracts
        GasSponsorship gasSponsorship = new GasSponsorship();
        ReputationNFT reputationNFT = new ReputationNFT();
        StreamingEscrow streamingEscrow = new StreamingEscrow();
        InsurancePool insurancePool = new InsurancePool();
        DisputeJury disputeJury = new DisputeJury();
        QualityVerification qualityVerification = new QualityVerification();

        // 2. Deploy the UserRegistry, passing the addresses of the contracts it depends on
        EnhancedUserRegistry userRegistry = new EnhancedUserRegistry(
            address(gasSponsorship),
            address(reputationNFT)
        );

        // 3. CRITICAL: Transfer ownership of the ReputationNFT contract to the UserRegistry contract
        // This allows the UserRegistry to mint NFTs.
        reputationNFT.transferOwnership(address(userRegistry));

        vm.stopBroadcast();

        // Log the deployed addresses for easy access
        console.log("GasSponsorship deployed at:", address(gasSponsorship));
        console.log("ReputationNFT deployed at:", address(reputationNFT));
        console.log("EnhancedUserRegistry deployed at:", address(userRegistry));
        console.log("StreamingEscrow deployed at:", address(streamingEscrow));
        console.log("InsurancePool deployed at:", address(insurancePool));
        console.log("DisputeJury deployed at:", address(disputeJury));
        console.log("QualityVerification deployed at:", address(qualityVerification));
    }
}