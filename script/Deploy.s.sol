// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/FranchiserController.sol";

contract DeployScript is Script {
    function run() external {
        // Load from environment
        address franchiserRig = vm.envOr("FRANCHISER_RIG", address(0x9310aF2707c458F52e1c4D48749433454D731060));
        address owner = vm.envAddress("OWNER_ADDRESS");
        address manager = vm.envAddress("MANAGER_ADDRESS");
        uint256 maxPrice = vm.envOr("MAX_PRICE_PER_TOKEN", uint256(0.001 ether));
        uint256 minMargin = vm.envOr("MIN_PROFIT_MARGIN", uint256(1000));
        
        console.log("Deploying FranchiserController...");
        console.log("Franchiser Rig:", franchiserRig);
        console.log("Owner:", owner);
        console.log("Manager:", manager);
        console.log("Max Price:", maxPrice);
        console.log("Min Margin:", minMargin);
        
        vm.startBroadcast();
        
        FranchiserController controller = new FranchiserController(
            franchiserRig,
            owner,
            manager,
            maxPrice,
            minMargin
        );
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("=== Deployment Complete ===");
        console.log("Controller:", address(controller));
        console.log("");
        console.log("Next Steps:");
        console.log("1. Add CONTROLLER_ADDRESS=%s to .env", address(controller));
        console.log("2. Fund controller: cast send %s --value 0.1ether", address(controller));
        console.log("3. Start monitor: npm run monitor");
        console.log("4. BaseScan: https://basescan.org/address/%s", address(controller));
    }
}
