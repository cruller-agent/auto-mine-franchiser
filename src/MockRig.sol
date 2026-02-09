// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockRig
 * @notice Mock Rig contract for testing that matches the actual IRig interface
 */
contract MockRig {
    uint256 private _currentPrice = 0.0005 ether;
    uint256 private _epochId = 1;
    address private _unit = address(0x1234567890123456789012345678901234567890);

    function mine(address miner, uint256 _epochId, uint256 deadline, uint256 maxPrice, string memory _epochUri)
        external
        payable
        returns (uint256 price)
    {
        require(msg.value >= _currentPrice, "Insufficient payment");
        require(_epochId == epochId(), "Invalid epoch");
        require(block.timestamp <= deadline, "Deadline passed");
        require(_currentPrice <= maxPrice, "Price exceeds max");
        
        // Mock: just accept the payment and return price
        return _currentPrice;
    }

    function epochId() public view returns (uint256) {
        return _epochId;
    }

    function getPrice() public view returns (uint256) {
        return _currentPrice;
    }

    function unit() public view returns (address) {
        return _unit;
    }

    // Test helpers
    function setPrice(uint256 newPrice) external {
        _currentPrice = newPrice;
    }

    function setEpoch(uint256 newEpoch) external {
        _epochId = newEpoch;
    }
}
