# Glazed Whale 🐋

Automated Franchiser token mining bot with smart contract controller. Monitors the Franchiser token (0x9310aF...31060) and executes profitable mining operations via an intermediary controller contract.

> **Built with Foundry** - Fast, modern Solidity development framework

## 🏗️ Architecture

```
┌─────────────┐      monitors      ┌──────────────┐
│   Monitor   │ ───────────────────> │  Franchiser  │
│   Script    │                     │  Rig Token   │
└──────┬──────┘                     └──────────────┘
       │
       │ triggers when profitable
       ↓
┌─────────────────┐      calls      ┌──────────────┐
│   Controller    │ ───────────────> │  Franchiser  │
│ Smart Contract  │                  │  Rig Token   │
└─────────────────┘                  └──────────────┘
```

### Components

1. **FranchiserController.sol** - Smart contract that:
   - Holds ETH for mining operations
   - Stores all configuration parameters onchain
   - Implements role-based access control:
     - **Owner**: Can withdraw funds and update config
     - **Manager**: Can trigger mining operations
   - Enforces safety limits (price thresholds, cooldowns, gas limits)

2. **monitor.js** - Monitoring script that:
   - Continuously checks Franchiser token mining price
   - Evaluates profitability against configured thresholds
   - Triggers controller to mint when conditions are met
   - Provides real-time stats and logging

## 🚀 Quick Start

### Prerequisites

- **Foundry** (forge, cast, anvil) - [Install here](https://book.getfoundry.sh/getting-started/installation)
- **Node.js 18+**
- Base mainnet wallet with ETH for deployment and mining

### Installation

```bash
# Clone repository
git clone https://github.com/cruller-agent/glazed-whale.git
cd glazed-whale

# Install Foundry (if needed)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install Node dependencies
npm install

# Install Foundry dependencies
forge install

# Copy environment template
cp .env.example .env
```

### Configuration

Edit `.env` with your details:

```bash
# Owner wallet (for deployment & withdrawals)
PRIVATE_KEY=0x...
OWNER_ADDRESS=0x...

# Manager wallet (for automated mining)
MANAGER_PRIVATE_KEY=0x...
MANAGER_ADDRESS=0x...

# Mining parameters
MAX_PRICE_PER_TOKEN=1000000000000000    # 0.001 ETH max price
MIN_PROFIT_MARGIN=1000                   # 10% minimum profit
```

### Build & Test

```bash
# Compile contracts
npm run build
# or: forge build

# Run tests
npm test
# or: forge test -vvv

# Run specific test
forge test --match-test testExecuteMint -vvv
```

### Deployment

```bash
# Deploy to Base mainnet
npm run deploy

# Or deploy to testnet first
npm run deploy:testnet

# After deployment, add CONTROLLER_ADDRESS to .env
CONTROLLER_ADDRESS=0x...
```

### Fund the Controller

Send ETH to the deployed controller address:

```bash
# Using cast (Foundry)
cast send $CONTROLLER_ADDRESS --value 0.1ether \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY

# Or send via MetaMask/wallet to the controller address
```

### Start Monitoring

```bash
# Start the monitor
npm run monitor

# Check status
npm run status

# Run in background with PM2
pm2 start scripts/monitor.js --name "glazed-whale"
pm2 save
```

## 📋 Configuration Parameters

All parameters are stored in the smart contract and can be updated by the owner:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `maxPricePerToken` | Maximum price willing to pay per token | 0.001 ETH |
| `minProfitMargin` | Minimum profit margin (basis points) | 1000 (10%) |
| `maxMintAmount` | Maximum tokens per transaction | 100 tokens |
| `minMintAmount` | Minimum tokens per transaction | 1 token |
| `autoMiningEnabled` | Global enable/disable switch | true |
| `cooldownPeriod` | Minimum time between mints | 300s (5 min) |
| `maxGasPrice` | Maximum gas price to pay | 10 gwei |

### Updating Configuration

```bash
# Update max price to 0.002 ETH
cast send $CONTROLLER_ADDRESS \
  "updateConfig(uint256,uint256,uint256,uint256,bool,uint256,uint256)" \
  2000000000000000 1000 100000000000000000000 1000000000000000000 true 300 10 \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

## 🔐 Access Control

### Owner Role
Can:
- Withdraw ETH and tokens
- Update configuration parameters
- Emergency stop mining
- Grant/revoke manager role

### Manager Role
Can:
- Execute mining operations
- Query profitability
- Check status

### Security Features
- ReentrancyGuard on all sensitive functions
- Role-based access control (OpenZeppelin)
- Configurable safety limits
- Emergency stop mechanism
- Event logging for all operations

## 💰 Economics

### Profitability Calculation

Mining executes when:
```
currentPrice ≤ maxPricePerToken
AND cooldownPeriod elapsed
AND gasPrice ≤ maxGasPrice
AND sufficient ETH balance
```

### Cost Analysis

**Deployment:**
- Contract deployment: ~0.003 ETH
- Configuration: Stored onchain

**Operation:**
- Mining cost: Variable (depends on Franchiser epoch)
- Gas per mint: ~200k-300k gas
- Monitor: Negligible (read-only checks)

## 📊 Monitoring & Stats

Check real-time status:

```bash
# Quick status check
npm run status

# Output shows:
🐋 Glazed Whale Status Report

📍 Controller: 0x...
🎯 Franchiser Rig: 0x9310aF...

⚙️  Configuration:
  Max Price: 0.001 ETH/token
  Auto Mining: ✅ ENABLED
  ETH Balance: 0.1 ETH

💰 Profitability:
  Status: ✅ PROFITABLE
  Current Price: 0.000876 ETH/token
```

## 🛠️ Advanced Usage

### Manual Operations

```bash
# Trigger manual mint (manager only)
cast send $CONTROLLER_ADDRESS \
  "executeMint(address,uint256)" \
  $RECIPIENT_ADDRESS 10000000000000000000 \
  --rpc-url $BASE_RPC_URL --private-key $MANAGER_PRIVATE_KEY

# Emergency stop (owner only)
cast send $CONTROLLER_ADDRESS "emergencyStop()" \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY

# Withdraw ETH (owner only)
cast send $CONTROLLER_ADDRESS \
  "withdrawETH(address,uint256)" \
  $OWNER_ADDRESS 0 \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

### Run in Production

```bash
# With PM2
pm2 start scripts/monitor.js --name "glazed-whale"
pm2 save
pm2 startup

# With systemd
sudo cp glazed-whale.service /etc/systemd/system/
sudo systemctl enable glazed-whale
sudo systemctl start glazed-whale
```

## 🧪 Testing

```bash
# Run all tests
forge test -vvv

# Run specific test
forge test --match-test testExecuteMint -vvv

# Run with gas report
forge test --gas-report

# Run with coverage
forge coverage
```

## 🔍 Contract Verification

After deployment:

```bash
forge verify-contract $CONTROLLER_ADDRESS \
  src/FranchiserController.sol:FranchiserController \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode \
    "constructor(address,address,address,uint256,uint256)" \
    $FRANCHISER_RIG $OWNER_ADDRESS $MANAGER_ADDRESS \
    $MAX_PRICE_PER_TOKEN $MIN_PROFIT_MARGIN) \
  --etherscan-api-key $BASESCAN_API_KEY
```

## 📚 Resources

- [Franchiser Documentation](https://github.com/cruller-agent/donutdao-app-scaffold/blob/main/contracts/donutdao-contracts/docs/FRANCHISE.md)
- [Foundry Book](https://book.getfoundry.sh/)
- [DonutDAO Ecosystem](https://donutdao.com)
- [Base Network](https://base.org)

## ⚠️ Disclaimer

This software is provided as-is. Always test thoroughly before deploying to mainnet. Monitor gas prices and market conditions. Never invest more than you can afford to lose.

## 📝 License

MIT

---

Built with ❤️ by Cruller for the DonutDAO ecosystem
