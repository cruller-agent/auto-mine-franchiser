# Auto-Mine Franchiser ⚙️

Generic automated mining bot for Franchiser-compatible tokens with configurable target. Set any Franchiser Rig contract address and let it auto-mine when profitable.

> **Built with Foundry** - Fast, modern Solidity development framework

## 🎯 Features

✅ **Configurable Target** - Set any Franchiser Rig contract address  
✅ **Owner-Updatable** - Change target rig without redeployment  
✅ **Fully Automated** - Set and forget mining operations  
✅ **Onchain Configuration** - All parameters stored in smart contract  
✅ **Role-Based Security** - Separate owner and manager permissions  
✅ **Safety Limits** - Price, gas, cooldown constraints  
✅ **Production Ready** - Tests, docs, systemd service  

## 🏗️ Architecture

```
┌─────────────┐      monitors      ┌──────────────┐
│   Monitor   │ ───────────────────> │ Target Rig   │
│   Script    │                     │  (Config)    │
└──────┬──────┘                     └──────────────┘
       │
       │ triggers when profitable
       ↓
┌─────────────────┐      calls      ┌──────────────┐
│   Controller    │ ───────────────> │ Target Rig   │
│ Smart Contract  │                  │  Token       │
└─────────────────┘                  └──────────────┘
```

### Components

1. **FranchiserController.sol** - Smart contract that:
   - Holds ETH for mining operations
   - Stores target rig address (owner can update)
   - Stores all configuration parameters onchain
   - Implements role-based access control:
     - **Owner**: Can withdraw funds, update config, change target rig
     - **Manager**: Can trigger mining operations
   - Enforces safety limits (price thresholds, cooldowns, gas limits)

2. **monitor.js** - Monitoring script that:
   - Continuously checks target rig mining price
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
git clone https://github.com/cruller-agent/auto-mine-franchiser.git
cd auto-mine-franchiser

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
# Target Rig to Mine (REQUIRED)
TARGET_RIG=0x9310aF2707c458F52e1c4D48749433454D731060  # Example: Default Franchiser Rig

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

# Run tests (18 tests)
npm test
# or: forge test -vvv

# Run specific test
forge test --match-test testUpdateTargetRig -vvv
```

### Deployment

```bash
# Deploy to Base mainnet (requires TARGET_RIG in .env)
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
pm2 start scripts/monitor.js --name "auto-mine-franchiser"
pm2 save
```

## 📋 Configuration Parameters

All parameters are stored in the smart contract and can be updated by the owner:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `targetRig` | Target Rig contract address to mine | Set at deployment |
| `maxPricePerToken` | Maximum price willing to pay per token | 0.001 ETH |
| `minProfitMargin` | Minimum profit margin (basis points) | 1000 (10%) |
| `maxMintAmount` | Maximum tokens per transaction | 100 tokens |
| `minMintAmount` | Minimum tokens per transaction | 1 token |
| `autoMiningEnabled` | Global enable/disable switch | true |
| `cooldownPeriod` | Minimum time between mints | 300s (5 min) |
| `maxGasPrice` | Maximum gas price to pay | 10 gwei |

### Updating Target Rig

The owner can change the target rig at any time:

```bash
# Update to a different Franchiser Rig
cast send $CONTROLLER_ADDRESS \
  "updateTargetRig(address)" \
  0xNEW_RIG_ADDRESS \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

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
- **Change target rig address**
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
- Mining cost: Variable (depends on target rig's epoch)
- Gas per mint: ~200k-300k gas
- Monitor: Negligible (read-only checks)

## 📊 Monitoring & Stats

Check real-time status:

```bash
# Quick status check
npm run status

# Output shows:
⚙️  Auto-Mine Franchiser Status

📍 Controller: 0x...
🎯 Target Rig: 0x9310aF...

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
# Check current target
cast call $CONTROLLER_ADDRESS "targetRig()" --rpc-url $BASE_RPC_URL

# Trigger manual mint (manager only)
cast send $CONTROLLER_ADDRESS \
  "executeMint(address,uint256)" \
  $RECIPIENT_ADDRESS 10000000000000000000 \
  --rpc-url $BASE_RPC_URL --private-key $MANAGER_PRIVATE_KEY

# Emergency stop (owner only)
cast send $CONTROLLER_ADDRESS "emergencyStop()" \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY

# Withdraw ETH (owner only, 0 = withdraw all)
cast send $CONTROLLER_ADDRESS \
  "withdrawETH(address,uint256)" \
  $OWNER_ADDRESS 0 \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

### Run in Production

```bash
# With PM2
pm2 start scripts/monitor.js --name "auto-mine-franchiser"
pm2 save
pm2 startup

# With systemd
sudo cp auto-mine-franchiser.service /etc/systemd/system/
sudo systemctl enable auto-mine-franchiser
sudo systemctl start auto-mine-franchiser
```

## 🧪 Testing

```bash
# Run all tests (18 tests)
forge test -vvv

# Test summary
forge test --summary

# Specific tests
forge test --match-test testUpdateTargetRig -vvv
forge test --match-test testExecuteMint -vvv

# Gas report
forge test --gas-report

# Coverage
forge coverage
```

### Test Coverage

- ✅ Deployment and role assignment
- ✅ Profitability checks
- ✅ Mining execution
- ✅ Cooldown periods
- ✅ Configuration updates
- ✅ **Target rig updates**
- ✅ Emergency stops
- ✅ Withdrawals
- ✅ Access control

## 🔍 Contract Verification

After deployment:

```bash
forge verify-contract $CONTROLLER_ADDRESS \
  src/FranchiserController.sol:FranchiserController \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode \
    "constructor(address,address,address,uint256,uint256)" \
    $TARGET_RIG $OWNER_ADDRESS $MANAGER_ADDRESS \
    $MAX_PRICE_PER_TOKEN $MIN_PROFIT_MARGIN) \
  --etherscan-api-key $BASESCAN_API_KEY
```

## 📚 Example Use Cases

### 1. Default Franchiser Rig
```bash
TARGET_RIG=0x9310aF2707c458F52e1c4D48749433454D731060
```

### 2. Switch to Different Rig Later
```bash
# Deploy with one rig
npm run deploy

# Later, switch to another rig (no redeployment needed)
cast send $CONTROLLER_ADDRESS "updateTargetRig(address)" 0xNEW_RIG \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

### 3. Multi-Rig Strategy
Deploy multiple controllers, each targeting different rigs for diversification.

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
