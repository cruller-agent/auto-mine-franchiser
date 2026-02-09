// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title FranchiserController
 * @notice Automated controller for Franchiser token mining with configurable parameters
 * @dev Implements role-based access: OWNER (withdrawals) and MANAGER (mining operations)
 */
interface IRig {
    function mine(address miner, uint256 _epochId, uint256 deadline, uint256 maxPrice, string memory _epochUri)
        external
        payable
        returns (uint256 price);
    function epochId() external view returns (uint256);
    function getPrice() external view returns (uint256);
    function unit() external view returns (address);
}

contract FranchiserController is AccessControl, ReentrancyGuard {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    // Target Rig contract address (can be updated by owner)
    address public targetRig;
    
    // Configuration parameters
    struct Config {
        uint256 maxPricePerToken;      // Maximum price willing to pay per token (in wei)
        uint256 minProfitMargin;       // Minimum profit margin required (basis points, e.g., 1000 = 10%)
        uint256 maxMintAmount;         // Maximum tokens to mint per transaction
        uint256 minMintAmount;         // Minimum tokens to mint per transaction
        bool autoMiningEnabled;        // Global enable/disable for auto mining
        uint256 cooldownPeriod;        // Minimum time between mints (seconds)
        uint256 maxGasPrice;           // Maximum gas price willing to pay (gwei)
    }

    Config public config;
    uint256 public lastMintTimestamp;
    
    // Events
    event ConfigUpdated(
        uint256 maxPricePerToken,
        uint256 minProfitMargin,
        uint256 maxMintAmount,
        uint256 minMintAmount,
        bool autoMiningEnabled,
        uint256 cooldownPeriod,
        uint256 maxGasPrice
    );
    event TargetRigUpdated(address indexed oldRig, address indexed newRig);
    event TokensMinted(address indexed recipient, uint256 amount, uint256 cost, uint256 epochId);
    event ETHWithdrawn(address indexed to, uint256 amount);
    event TokensWithdrawn(address indexed token, address indexed to, uint256 amount);
    event EmergencyStop(address indexed by);

    constructor(
        address _targetRig,
        address _owner,
        address _manager,
        uint256 _maxPricePerToken,
        uint256 _minProfitMargin
    ) {
        require(_targetRig != address(0), "Invalid rig address");
        require(_owner != address(0), "Invalid owner");
        require(_manager != address(0), "Invalid manager");

        targetRig = _targetRig;

        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(OWNER_ROLE, _owner);
        _grantRole(MANAGER_ROLE, _manager);

        // Initialize config with sensible defaults
        config = Config({
            maxPricePerToken: _maxPricePerToken,
            minProfitMargin: _minProfitMargin,
            maxMintAmount: 100 ether,
            minMintAmount: 1 ether,
            autoMiningEnabled: true,
            cooldownPeriod: 300, // 5 minutes
            maxGasPrice: 10 gwei
        });
    }

    /**
     * @notice Update target rig address (OWNER only)
     * @param _newRig New rig contract address
     */
    function updateTargetRig(address _newRig) external onlyRole(OWNER_ROLE) {
        require(_newRig != address(0), "Invalid rig address");
        address oldRig = targetRig;
        targetRig = _newRig;
        emit TargetRigUpdated(oldRig, _newRig);
    }

    /**
     * @notice Check if mining is profitable at current price
     * @return isProfitable Whether mining is profitable
     * @return currentPrice Current price from rig
     * @return recommendedAmount Recommended amount to mint (always maxMintAmount if profitable)
     */
    function checkProfitability() 
        public 
        view 
        returns (
            bool isProfitable,
            uint256 currentPrice,
            uint256 recommendedAmount
        ) 
    {
        currentPrice = IRig(targetRig).getPrice();
        
        // Check if price is below max threshold
        if (currentPrice > config.maxPricePerToken) {
            return (false, currentPrice, 0);
        }

        // Calculate profit margin (simplified - assumes external price oracle would be used)
        // For now, just check if we're below max price
        isProfitable = currentPrice <= config.maxPricePerToken;
        
        // Note: Rig's mine() function doesn't take amount - it mints based on current UPS
        // So recommendedAmount is informational only
        recommendedAmount = isProfitable ? config.maxMintAmount : 0;
    }

    /**
     * @notice Execute mining operation (MANAGER only)
     * @param recipient Address to receive minted tokens
     * @param epochUri URI for epoch metadata (optional, can be empty)
     */
    function executeMine(address recipient, string memory epochUri) 
        external 
        onlyRole(MANAGER_ROLE) 
        nonReentrant 
        returns (uint256 price)
    {
        require(config.autoMiningEnabled, "Auto mining disabled");
        require(block.timestamp >= lastMintTimestamp + config.cooldownPeriod, "Cooldown active");
        require(tx.gasprice <= config.maxGasPrice * 1 gwei, "Gas price too high");

        // Get current epoch and price
        uint256 currentEpochId = IRig(targetRig).epochId();
        uint256 currentPrice = IRig(targetRig).getPrice();
        
        // Check price is acceptable
        require(currentPrice <= config.maxPricePerToken, "Price too high");
        require(address(this).balance >= currentPrice, "Insufficient ETH balance");

        // Execute mine - Rig determines amount based on UPS
        // deadline = current block timestamp (immediate execution)
        // maxPrice = our configured max price
        price = IRig(targetRig).mine{value: currentPrice}(
            recipient,
            currentEpochId,
            block.timestamp,
            config.maxPricePerToken,
            epochUri
        );
        
        lastMintTimestamp = block.timestamp;
        
        // Note: We don't know the exact amount minted (determined by Rig's UPS)
        // Emit event with price paid
        emit TokensMinted(recipient, 0, price, currentEpochId);
    }

    /**
     * @notice Update configuration (OWNER only)
     */
    function updateConfig(
        uint256 _maxPricePerToken,
        uint256 _minProfitMargin,
        uint256 _maxMintAmount,
        uint256 _minMintAmount,
        bool _autoMiningEnabled,
        uint256 _cooldownPeriod,
        uint256 _maxGasPrice
    ) external onlyRole(OWNER_ROLE) {
        require(_maxMintAmount >= _minMintAmount, "Invalid mint amounts");
        require(_cooldownPeriod <= 1 days, "Cooldown too long");
        require(_maxGasPrice > 0, "Invalid gas price");

        config.maxPricePerToken = _maxPricePerToken;
        config.minProfitMargin = _minProfitMargin;
        config.maxMintAmount = _maxMintAmount;
        config.minMintAmount = _minMintAmount;
        config.autoMiningEnabled = _autoMiningEnabled;
        config.cooldownPeriod = _cooldownPeriod;
        config.maxGasPrice = _maxGasPrice;

        emit ConfigUpdated(
            _maxPricePerToken,
            _minProfitMargin,
            _maxMintAmount,
            _minMintAmount,
            _autoMiningEnabled,
            _cooldownPeriod,
            _maxGasPrice
        );
    }

    /**
     * @notice Emergency stop (OWNER only)
     */
    function emergencyStop() external onlyRole(OWNER_ROLE) {
        config.autoMiningEnabled = false;
        emit EmergencyStop(msg.sender);
    }

    /**
     * @notice Withdraw ETH (OWNER only)
     * @param to Recipient address
     * @param amount Amount to withdraw (0 = all)
     */
    function withdrawETH(address payable to, uint256 amount) 
        external 
        onlyRole(OWNER_ROLE) 
        nonReentrant 
    {
        require(to != address(0), "Invalid recipient");
        
        uint256 withdrawAmount = amount == 0 ? address(this).balance : amount;
        require(withdrawAmount > 0, "No ETH to withdraw");
        require(address(this).balance >= withdrawAmount, "Insufficient balance");

        (bool success, ) = to.call{value: withdrawAmount}("");
        require(success, "ETH transfer failed");

        emit ETHWithdrawn(to, withdrawAmount);
    }

    /**
     * @notice Withdraw ERC20 tokens (OWNER only)
     * @param token Token contract address
     * @param to Recipient address
     * @param amount Amount to withdraw (0 = all)
     */
    function withdrawTokens(address token, address to, uint256 amount) 
        external 
        onlyRole(OWNER_ROLE) 
        nonReentrant 
    {
        require(token != address(0), "Invalid token");
        require(to != address(0), "Invalid recipient");

        IERC20 tokenContract = IERC20(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        uint256 withdrawAmount = amount == 0 ? balance : amount;
        
        require(withdrawAmount > 0, "No tokens to withdraw");
        require(balance >= withdrawAmount, "Insufficient token balance");

        require(tokenContract.transfer(to, withdrawAmount), "Token transfer failed");

        emit TokensWithdrawn(token, to, withdrawAmount);
    }

    /**
     * @notice Get current mining status
     */
    function getMiningStatus() external view returns (
        bool isEnabled,
        bool canMintNow,
        uint256 currentPrice,
        uint256 nextMintTime,
        uint256 ethBalance,
        uint256 currentEpochId
    ) {
        isEnabled = config.autoMiningEnabled;
        currentPrice = IRig(targetRig).getPrice();
        canMintNow = (currentPrice <= config.maxPricePerToken) && 
                     (block.timestamp >= lastMintTimestamp + config.cooldownPeriod);
        nextMintTime = lastMintTimestamp + config.cooldownPeriod;
        ethBalance = address(this).balance;
        currentEpochId = IRig(targetRig).epochId();
    }

    /**
     * @notice Receive ETH
     */
    receive() external payable {}
}
