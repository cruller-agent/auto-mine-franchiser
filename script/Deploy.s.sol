// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/FranchiserController.sol";

contract DeployScript is Script {
    function run() external {
        // Load from environment
        address targetRig = vm.envAddress("TARGET_RIG");  // Required - no default
        address owner = vm.envAddress("OWNER_ADDRESS");
        address manager = vm.envAddress("MANAGER_ADDRESS");
        uint256 maxPrice = vm.envOr("MAX_PRICE_PER_TOKEN", uint256(0.001 ether));
        uint256 minMargin = vm.envOr("MIN_PROFIT_MARGIN", uint256(1000));
        
        console.log("Deploying FranchiserController...");
        console.log("Target Rig:", targetRig);
        console.log("Owner:", owner);
        console.log("Manager:", manager);
        console.log("Max Price:", maxPrice);
        console.log("Min Margin:", minMargin);
        
        vm.startBroadcast();
        
        FranchiserController controller = new FranchiserController(
            targetRig,
            owner,
            manager,
            maxPrice,
            minMargin
        );
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("=== Deployment Complete ===");
        console.log("Controller:", address(controller));
        console.log("Target Rig:", targetRig);
        console.log("");
        console.log("Next Steps:");
        console.log("1. Add CONTROLLER_ADDRESS=%s to .env", address(controller));
        console.log("2. Fund controller: cast send %s --value 0.1ether", address(controller));
        console.log("3. Update monitor TARGET_RIG if needed");
        console.log("4. Start monitor: npm run monitor");
        console.log("5. BaseScan: https://basescan.org/address/%s", address(controller));
    }
}
