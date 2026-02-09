// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockRig
 * @notice Mock Rig contract for testing that matches the actual IRig interface
 * Uses ERC20 transferFrom for payment (like real Rig)
 * Implements full IRig interface from Heesho's reference
 */
contract MockRig is Ownable {
    using SafeERC20 for IERC20;
    
    uint256 private _currentPrice = 0.0005 ether;
    uint256 private _epochId = 1;
    uint256 private _epochInitPrice = 0.001 ether;
    uint256 private _epochStartTime;
    uint256 private _epochUps = 1e18;
    address private _epochMiner;
    string private _epochUri = "";
    string private _uri = "mock://uri";
    
    address private _unit;
    address private _quote; // Payment token (e.g., WETH)
    
    constructor(address quoteToken_, address unitToken_) {
        _quote = quoteToken_;
        _unit = unitToken_;
        _epochMiner = msg.sender;
        _epochStartTime = block.timestamp;
    }
    
    function mine(address miner, uint256 epochId_, uint256 deadline, uint256 maxPrice, string calldata epochUri_)
        external
        returns (uint256 price)
    {
        require(epochId_ == _epochId, "Rig__EpochIdMismatch");
        require(block.timestamp <= deadline, "Rig__Expired");
        
        price = getPrice();
        require(price <= maxPrice, "Rig__MaxPriceExceeded");
        require(miner != address(0), "Rig__InvalidMiner");
        
        // Pull payment via transferFrom (like real Rig)
        IERC20(_quote).safeTransferFrom(msg.sender, address(this), price);
        
        // Update state for new epoch
        _epochMiner = miner;
        _epochStartTime = block.timestamp;
        _epochUri = epochUri_;
        unchecked {
            _epochId++;
        }
        
        return price;
    }
    
    // IRig interface implementation
    function epochId() external view returns (uint256) {
        return _epochId;
    }
    
    function epochInitPrice() external view returns (uint256) {
        return _epochInitPrice;
    }
    
    function epochStartTime() external view returns (uint256) {
        return _epochStartTime;
    }
    
    function epochUps() external view returns (uint256) {
        return _epochUps;
    }
    
    function epochMiner() external view returns (address) {
        return _epochMiner;
    }
    
    function epochUri() external view returns (string memory) {
        return _epochUri;
    }
    
    function uri() external view returns (string memory) {
        return _uri;
    }
    
    function unit() external view returns (address) {
        return _unit;
    }
    
    function quote() external view returns (address) {
        return _quote;
    }
    
    function getPrice() public view returns (uint256) {
        return _currentPrice;
    }
    
    function getUps() external view returns (uint256) {
        return _epochUps;
    }
    
    // Test helpers
    function setPrice(uint256 newPrice) external {
        _currentPrice = newPrice;
    }
    
    function setEpoch(uint256 newEpoch) external {
        _epochId = newEpoch;
    }
    
    function setEpochUps(uint256 newUps) external {
        _epochUps = newUps;
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
