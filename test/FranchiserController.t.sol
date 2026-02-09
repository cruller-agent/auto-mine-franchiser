// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/FranchiserController.sol";
import "../src/MockRig.sol";

contract FranchiserControllerTest is Test {
    FranchiserController public controller;
    MockRig public mockRig;
    
    address public owner;
    address public manager;
    address public user;
    
    receive() external payable {}
    
    uint256 constant MAX_PRICE = 0.001 ether;
    uint256 constant MIN_MARGIN = 1000; // 10%
    
    event TokensMinted(address indexed recipient, uint256 amount, uint256 cost, uint256 epochId);
    event ConfigUpdated(
        uint256 maxPricePerToken,
        uint256 minProfitMargin,
        uint256 maxMintAmount,
        uint256 minMintAmount,
        bool autoMiningEnabled,
        uint256 cooldownPeriod,
        uint256 maxGasPrice
    );
    event ETHWithdrawn(address indexed to, uint256 amount);
    event TokensWithdrawn(address indexed token, address indexed to, uint256 amount);
    event EmergencyStop(address indexed by);
    
    function setUp() public {
        owner = address(this);
        manager = makeAddr("manager");
        user = makeAddr("user");
        
        // Deploy mock rig
        mockRig = new MockRig();
        
        // Deploy controller
        controller = new FranchiserController(
            address(mockRig),
            owner,
            manager,
            MAX_PRICE,
            MIN_MARGIN
        );
        
        // Fund controller
        vm.deal(address(controller), 10 ether);
    }
    
    function testDeployment() public {
        bytes32 OWNER_ROLE = keccak256("OWNER_ROLE");
        bytes32 MANAGER_ROLE = keccak256("MANAGER_ROLE");
        
        assertTrue(controller.hasRole(OWNER_ROLE, owner));
        assertTrue(controller.hasRole(MANAGER_ROLE, manager));
        
        (
            uint256 maxPrice,
            uint256 minMargin,
            ,
            ,
            bool enabled,
            ,
            
        ) = controller.config();
        
        assertEq(maxPrice, MAX_PRICE);
        assertEq(minMargin, MIN_MARGIN);
        assertTrue(enabled);
    }
    
    function testCheckProfitability() public view {
        (bool isProfitable, uint256 currentPrice, uint256 recommendedAmount) = controller.checkProfitability();
        
        assertEq(currentPrice, 0.0005 ether); // Mock price
        assertTrue(isProfitable);
        assertGt(recommendedAmount, 0);
    }
    
    function testExecuteMint() public {
        uint256 amount = 10 ether;
        uint256 cost = mockRig.quote(amount);
        
        // Warp forward to clear any initial cooldown
        vm.warp(block.timestamp + 301);
        
        vm.expectEmit(true, false, false, true);
        emit TokensMinted(user, amount, cost, 1);
        
        vm.prank(manager);
        controller.executeMint(user, amount);
        
        assertEq(controller.lastMintTimestamp(), block.timestamp);
    }
    
    function testExecuteMintNonManager() public {
        uint256 amount = 10 ether;
        
        vm.prank(user);
        vm.expectRevert();
        controller.executeMint(user, amount);
    }
    
    function testExecuteMintWithCooldown() public {
        uint256 amount = 10 ether;
        
        // Warp forward to clear any initial cooldown
        vm.warp(block.timestamp + 301);
        
        // First mint
        vm.prank(manager);
        controller.executeMint(user, amount);
        
        // Try immediate second mint (should fail)
        vm.prank(manager);
        vm.expectRevert("Cooldown active");
        controller.executeMint(user, amount);
        
        // Wait for cooldown
        vm.warp(block.timestamp + 301);
        
        // Now should work
        vm.prank(manager);
        controller.executeMint(user, amount);
    }
    
    function testUpdateConfig() public {
        uint256 newMaxPrice = 0.002 ether;
        
        vm.expectEmit(true, true, true, true);
        emit ConfigUpdated(
            newMaxPrice,
            2000,
            200 ether,
            2 ether,
            true,
            600,
            20
        );
        
        controller.updateConfig(
            newMaxPrice,
            2000,
            200 ether,
            2 ether,
            true,
            600,
            20
        );
        
        (uint256 maxPrice, , , , , , ) = controller.config();
        assertEq(maxPrice, newMaxPrice);
    }
    
    function testUpdateConfigNonOwner() public {
        vm.prank(manager);
        vm.expectRevert();
        controller.updateConfig(
            MAX_PRICE,
            MIN_MARGIN,
            100 ether,
            1 ether,
            true,
            300,
            10
        );
    }
    
    function testEmergencyStop() public {
        vm.expectEmit(true, true, true, true);
        emit EmergencyStop(owner);
        
        controller.emergencyStop();
        
        (, , , , bool enabled, , ) = controller.config();
        assertFalse(enabled);
    }
    
    function testWithdrawETH() public {
        uint256 withdrawAmount = 1 ether;
        uint256 balanceBefore = owner.balance;
        uint256 controllerBalanceBefore = address(controller).balance;
        
        controller.withdrawETH(payable(owner), withdrawAmount);
        
        assertEq(owner.balance, balanceBefore + withdrawAmount);
        assertEq(address(controller).balance, controllerBalanceBefore - withdrawAmount);
    }
    
    function testWithdrawETHNonOwner() public {
        vm.prank(manager);
        vm.expectRevert();
        controller.withdrawETH(payable(manager), 1 ether);
    }
    
    function testGetMiningStatus() public {
        (
            bool isEnabled,
            bool canMintNow,
            uint256 currentPrice,
            uint256 nextMintTime,
            uint256 ethBalance,
            uint256 currentEpochId
        ) = controller.getMiningStatus();
        
        assertTrue(isEnabled);
        // canMintNow depends on cooldown and timestamp
        assertEq(currentPrice, 0.0005 ether);
        assertGt(nextMintTime, 0); // Will have cooldown from lastMintTimestamp
        assertEq(ethBalance, 10 ether);
        assertEq(currentEpochId, 1);
    }
    
    function testPriceExceedsMaximum() public {
        // Set high price in mock
        mockRig.setPrice(0.002 ether);
        
        // Warp forward to clear cooldown
        vm.warp(block.timestamp + 301);
        
        vm.prank(manager);
        vm.expectRevert("Price too high");
        controller.executeMint(user, 10 ether);
    }
    
    function testInsufficientBalance() public {
        // Drain controller
        controller.withdrawETH(payable(owner), address(controller).balance);
        
        // Warp forward to clear cooldown
        vm.warp(block.timestamp + 301);
        
        vm.prank(manager);
        vm.expectRevert("Insufficient ETH balance");
        controller.executeMint(user, 10 ether);
    }
    
    function testMintAmountBounds() public {
        // Too small
        vm.prank(manager);
        vm.expectRevert("Amount out of bounds");
        controller.executeMint(user, 0.5 ether);
        
        // Too large
        vm.prank(manager);
        vm.expectRevert("Amount out of bounds");
        controller.executeMint(user, 150 ether);
    }
    
    function testReceiveETH() public {
        uint256 balanceBefore = address(controller).balance;
        
        (bool success, ) = address(controller).call{value: 1 ether}("");
        assertTrue(success);
        
        assertEq(address(controller).balance, balanceBefore + 1 ether);
    }
}
