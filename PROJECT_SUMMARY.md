# Auto-Mine Franchiser ⚙️ - Project Summary

**Repository:** https://github.com/cruller-agent/auto-mine-franchiser  
**Created:** 2026-02-09  
**Version:** 2.0.0  
**Status:** ✅ Production Ready

## Overview

Auto-Mine Franchiser is a generic automated mining bot for Franchiser-compatible tokens. Deploy once and mine any Franchiser Rig contract - switch targets on the fly without redeployment.

## What It Does

Continuously monitors a configured Franchiser Rig contract and automatically mines tokens when the price meets profitability thresholds. The target rig is stored onchain and can be updated by the owner at any time.

## Architecture

### Smart Contract (`FranchiserController.sol`)
- **Purpose:** Holds ETH and executes mining operations with safety constraints
- **Access Control:** 
  - Owner role: Withdraw funds, update config, **change target rig**
  - Manager role: Trigger mining operations
- **Safety Features:**
  - Configurable price thresholds
  - Cooldown periods
  - Gas price limits
  - Emergency stop mechanism
- **Configuration stored onchain:**
  - Target rig address (updatable)
  - Max mining price (one-time price per mining action)
  - Profit margin requirements
  - Mint amount limits
  - Timing constraints

### Monitor Script (`monitor.js`)
- **Purpose:** Continuously monitors and triggers profitable mining
- **Features:**
  - Real-time profitability checks
  - Automatic execution when conditions met
  - Statistics tracking
  - Error handling and recovery
  - Graceful shutdown

## Key Features

✅ **Configurable Target** - Set any Franchiser Rig contract address  
✅ **Owner-Updatable** - Change target without redeployment  
✅ **Fully Automated** - Set and forget mining operations  
✅ **Onchain Configuration** - All parameters stored in smart contract  
✅ **Role-Based Security** - Separate owner and manager permissions  
✅ **Safety Limits** - Price, gas, cooldown constraints  
✅ **Production Ready** - 18/18 tests passing, comprehensive docs  

## Technical Stack

- **Smart Contracts:** Solidity 0.8.20, OpenZeppelin, Foundry
- **Runtime:** Node.js 18+, ethers.js v6
- **Network:** Base mainnet (Chain ID 8453)
- **Testing:** Foundry test suite with mocks

## Deployment Guide

1. **Set TARGET_RIG:** Add target Franchiser Rig address to .env (required)
2. **Install dependencies:** `npm install && forge install`
3. **Configure environment:** Copy `.env.example` to `.env` and fill in values
4. **Compile contracts:** `npm run build`
5. **Run tests:** `npm test`
6. **Deploy to Base:** `npm run deploy`
7. **Fund controller:** Send ETH to deployed address
8. **Start monitoring:** `npm run monitor`

## Configuration Parameters

| Parameter | Owner Updatable? | Default | Description |
|-----------|-----------------|---------|-------------|
| `targetRig` | ✅ Yes | Set at deploy | Target Rig contract to mine |
| `maxMiningPrice` | ✅ Yes | 0.001 ETH | Maximum price to pay per mining action |
| `minProfitMargin` | ✅ Yes | 10% | Minimum profit required |
| `cooldownPeriod` | ✅ Yes | 300s | Time between mints |
| `maxGasPrice` | ✅ Yes | 10 gwei | Gas price limit |

## Use Cases

- **Single Rig Mining:** Deploy and mine one Franchiser token
- **Multi-Rig Strategy:** Switch between different tokens without redeployment
- **Diversification:** Deploy multiple controllers for different rigs
- **Opportunistic Mining:** Change targets based on market conditions
- **DAO Treasury:** Autonomous treasury management

## Security Considerations

- ✅ Role-based access control (OpenZeppelin)
- ✅ ReentrancyGuard on sensitive functions
- ✅ Input validation and bounds checking
- ✅ Event logging for all operations
- ✅ Emergency stop capability
- ✅ Separate hot/cold wallet support (owner vs manager)

## Future Enhancements

Potential additions:
- [ ] DEX price oracle integration for true profit calculation
- [ ] Multiple token support (parallel mining)
- [ ] Telegram/Discord notifications
- [ ] Web dashboard for monitoring
- [ ] Historical performance analytics
- [ ] Advanced strategies (epoch timing, auction participation)

## Economics

**Deployment Cost:** ~0.003 ETH  
**Per-Mint Gas:** ~200k-300k gas (~0.002-0.003 ETH at 10 gwei)  
**Mining Cost:** Variable (depends on target rig's epoch)  
**Potential Returns:** Depends on token price appreciation

## Major Changes (v2.0)

### From Glazed Whale (v1.0):
- ✅ Renamed for generic use
- ✅ Made target rig configurable (was immutable)
- ✅ Added `updateTargetRig()` function
- ✅ Added `TargetRigUpdated` event
- ✅ Converted from Hardhat to Foundry
- ✅ Added 3 new tests (18 total)
- ✅ Complete documentation rewrite

### Key Innovation:
```solidity
// v1.0 (immutable)
address public immutable franchiserRig;

// v2.0 (configurable)
address public targetRig;
function updateTargetRig(address _newRig) external onlyOwner;
```

## Links

- **Repository:** https://github.com/cruller-agent/auto-mine-franchiser
- **Quick Start:** [QUICKSTART.md](./QUICKSTART.md)
- **Documentation:** [README.md](./README.md)
- **Franchiser Docs:** [FRANCHISE.md](https://github.com/cruller-agent/donutdao-app-scaffold/blob/main/contracts/donutdao-contracts/docs/FRANCHISE.md)
- **DonutDAO:** https://donutdao.com
- **Base Network:** https://base.org

## License

MIT - Open source and permissionless

## Credits

Built by Cruller (@cruller_donut) for the DonutDAO ecosystem.

Special thanks to the Franchiser and Base communities.

---

**Note:** This is experimental software. Always test thoroughly before deploying to mainnet. Never invest more than you can afford to lose.
