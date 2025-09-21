// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GasSponsorship is Ownable {
    event DepositReceived(address indexed from, uint256 amount);
    event FundsWithdrawn(address indexed to, uint256 amount);

    // --- THIS IS THE FIX ---
    // We add a constructor that calls the Ownable constructor,
    // setting the deployer of this contract as the initial owner.
    constructor() Ownable(msg.sender) {}

    function addDeposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        emit DepositReceived(msg.sender, msg.value);
    }

    function withdrawToRelayer(address payable _relayer, uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient funds in pool");
        (bool success, ) = _relayer.call{value: _amount}("");
        require(success, "Failed to send funds");
        emit FundsWithdrawn(_relayer, _amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}