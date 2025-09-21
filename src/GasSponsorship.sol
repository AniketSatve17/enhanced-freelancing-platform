// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

// This contract holds the collective funds for sponsoring user gas fees.
contract GasSponsorship is Ownable {
    event DepositReceived(address indexed from, uint256 amount);
    event FundsWithdrawn(address indexed to, uint256 amount);

    // Explicitly set the deployer as the initial owner (for OpenZeppelin v5+).
    constructor() Ownable(msg.sender) {}

    // This function allows other contracts to send Ether deposits to this pool.
    function addDeposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        emit DepositReceived(msg.sender, msg.value);
    }

    // Allows the platform owner to withdraw funds, for example, to pay a gas relayer service.
    function withdrawFunds(address payable _to, uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient funds in pool");
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send funds");
        emit FundsWithdrawn(_to, _amount);
    }

    // A function to check the balance of the gas pool.
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}