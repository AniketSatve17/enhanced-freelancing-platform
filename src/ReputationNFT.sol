// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ReputationNFT is ERC721, Ownable {
    struct TrialBadge {
        string skillArea;
        uint256 score;
        address issuer;
        uint256 timestamp;
    }

    mapping(uint256 => TrialBadge) public trialBadges;
    uint256 public nextTokenId = 1;

    event TrialBadgeMinted(address indexed owner, uint256 indexed tokenId, string skillArea);

    // --- THIS IS THE FIX ---
    // We add Ownable(msg.sender) here to explicitly set the owner on deployment.
    constructor() ERC721("Freelance Credentials", "FLCRED") Ownable(msg.sender) {}

    function mintCredential(
        address _freelancer,
        string memory _skillArea,
        uint256 _score,
        address _issuer
    ) external onlyOwner returns (uint256) {
        uint256 tokenId = nextTokenId++;
        
        trialBadges[tokenId] = TrialBadge({
            skillArea: _skillArea,
            score: _score,
            issuer: _issuer,
            timestamp: block.timestamp
        });

        _mint(_freelancer, tokenId);
        emit TrialBadgeMinted(_freelancer, tokenId, _skillArea);
        return tokenId;
    }
}