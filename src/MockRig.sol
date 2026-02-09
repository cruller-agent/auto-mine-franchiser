// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MockRig
 * @notice Mock Rig contract for testing that matches the actual IRig interface
 * Uses ERC20 transferFrom for payment (like real Rig)
 */
contract MockRig {
    using SafeERC20 for IERC20;
    
    uint256 private _currentPrice = 0.0005 ether;
    uint256 private _epochId = 1;
    address private _unit = address(0x1234567890123456789012345678901234567890);
    address private _quote; // Payment token (e.g., WETH)
    
    constructor(address quoteToken_) {
        _quote = quoteToken_;
    }
    
    function mine(address miner, uint256 _epochId, uint256 deadline, uint256 maxPrice, string memory _epochUri)
        external
        returns (uint256 price)
    {
        require(_epochId == epochId(), "Invalid epoch");
        require(block.timestamp <= deadline, "Expired");
        
        price = getPrice();
        require(price <= maxPrice, "Max price exceeded");
        
        // Pull payment via transferFrom (like real Rig)
        IERC20(_quote).safeTransferFrom(msg.sender, address(this), price);
        
        // Increment epoch
        _epochId++;
        
        return price;
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
    
    function quote() external view returns (address) {
        return _quote;
    }
    
    // Test helpers
    function setPrice(uint256 newPrice) external {
        _currentPrice = newPrice;
    }
    
    function setEpoch(uint256 newEpoch) external {
        _epochId = newEpoch;
    }
}

/**
 * @title MockERC20
 * @notice Simple ERC20 mock for testing
 */
contract MockERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}
