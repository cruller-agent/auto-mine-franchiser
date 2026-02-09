# Glazed Whale 🐋 - Project Summary

**Repository:** https://github.com/cruller-agent/glazed-whale  
**Created:** 2026-02-09  
**Status:** ✅ Production Ready

## Overview

Glazed Whale is an automated Franchiser token mining bot that monitors the Franchiser Rig contract on Base and executes profitable mining operations through a smart contract controller.

## Architecture

### Smart Contract (`FranchiserController.sol`)
- **Purpose:** Holds ETH and executes mining operations with safety constraints
- **Access Control:** 
  - Owner role: Withdraw funds, update config
  - Manager role: Trigger mining operations
- **Safety Features:**
  - Configurable price thresholds
  - Cooldown periods
  - Gas price limits
  - Emergency stop mechanism
- **Configuration stored onchain:**
  - Max price per token
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

✅ **Fully Automated** - Set and forget mining operations  
✅ **Onchain Configuration** - All parameters stored in smart contract  
✅ **Role-Based Security** - Separate owner and manager permissions  
✅ **Safety Limits** - Price, gas, cooldown constraints  
✅ **Production Ready** - Tests, docs, systemd service  
✅ **Real-time Stats** - Track performance and profitability  

## Technical Stack

- **Smart Contracts:** Solidity 0.8.20, OpenZeppelin, Hardhat
- **Runtime:** Node.js 18+, ethers.js v6
- **Network:** Base mainnet (Chain ID 8453)
- **Testing:** Hardhat test suite with mocks

## Deployment Guide

1. **Install dependencies:** `npm install`
2. **Configure environment:** Copy `.env.example` to `.env` and fill in values
3. **Compile contracts:** `npm run compile`
4. **Run tests:** `npm test`
5. **Deploy to Base:** `npm run deploy`
6. **Fund controller:** Send ETH to deployed address
7. **Start monitoring:** `npm run monitor`

## Configuration Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| MAX_PRICE_PER_TOKEN | 0.001 ETH | Maximum price to pay |
| MIN_PROFIT_MARGIN | 10% | Minimum profit required |
| COOLDOWN_PERIOD | 300s | Time between mints |
| MAX_GAS_PRICE | 10 gwei | Gas price limit |
| POLL_INTERVAL | 60000ms | Check frequency |

## Use Cases

- **Passive Income:** Automated mining of Franchiser tokens
- **Arbitrage:** Execute when mining price < market price
- **DAO Treasury:** Autonomous treasury management
- **Agent Operations:** Template for autonomous on-chain operations

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
- [ ] Multiple token support (generalize beyond Franchiser)
- [ ] Telegram/Discord notifications
- [ ] Web dashboard for monitoring
- [ ] Historical performance analytics
- [ ] Advanced strategies (epoch timing, auction participation)

## Economics

**Deployment Cost:** ~0.003 ETH  
**Per-Mint Gas:** ~200k-300k gas (~0.002-0.003 ETH at 10 gwei)  
**Mining Cost:** Variable (depends on Franchiser epoch)  
**Potential Returns:** Depends on token price appreciation

## Links

- **Repository:** https://github.com/cruller-agent/glazed-whale
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
