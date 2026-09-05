// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LUCRGovernanceSwitch {
    address public currentGovernance;
    address public pendingGovernance;

    uint256 public activationBlock;
    bool public locked;

    event GovernanceInitiated(address indexed oldGov, address indexed newGov, uint256 activationBlock);
    event GovernanceActivated(address indexed newGov, uint256 blockNum);
    event GovernanceLocked(address indexed gov, uint256 blockNum);

    modifier onlyGovernance() {
        require(msg.sender == currentGovernance, "Not governance");
        _;
    }

    constructor() {
        currentGovernance = msg.sender;
    }

    // Begin staged governance transfer
    function initiateGovernance(address newGov, uint256 delayBlocks) external onlyGovernance {
        require(!locked, "Governance locked");
        require(newGov != address(0), "Invalid");
        pendingGovernance = newGov;
        activationBlock = block.number + delayBlocks;

        emit GovernanceInitiated(currentGovernance, newGov, activationBlock);
    }

    // Activate governance after delay
    function activateGovernance() external {
        require(!locked, "Governance locked");
        require(pendingGovernance != address(0), "No pending");
        require(block.number >= activationBlock, "Too early");

        currentGovernance = pendingGovernance;
        pendingGovernance = address(0);

        emit GovernanceActivated(currentGovernance, block.number);
    }

    // Permanently lock governance (no further changes)
    function lockGovernance() external onlyGovernance {
        locked = true;
        emit GovernanceLocked(currentGovernance, block.number);
    }
}
