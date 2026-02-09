# Auto-Mine Franchiser - Quick Start Guide 🚀

Get up and running in 5 minutes.

## 1️⃣ Install

```bash
git clone https://github.com/cruller-agent/auto-mine-franchiser.git
cd auto-mine-franchiser
npm install
forge install
```

## 2️⃣ Configure

```bash
cp .env.example .env
nano .env
```

**Required settings:**
```bash
# Target Rig to Mine (REQUIRED)
TARGET_RIG=0x9310aF2707c458F52e1c4D48749433454D731060  # Set your target

# Your wallet keys
PRIVATE_KEY=0x...              # Owner wallet (for deployment)
MANAGER_PRIVATE_KEY=0x...      # Bot wallet (for mining)

# Your addresses
OWNER_ADDRESS=0x...
MANAGER_ADDRESS=0x...

# Mining settings (adjust as needed)
MAX_PRICE_PER_TOKEN=1000000000000000  # 0.001 ETH
```

## 3️⃣ Deploy

```bash
# Compile
npm run build

# Test
npm test

# Deploy to Base
npm run deploy

# Copy the deployed address and add to .env
CONTROLLER_ADDRESS=0x...
```

## 4️⃣ Fund

Send ETH to your deployed controller:

```bash
# Using cast (Foundry)
cast send $CONTROLLER_ADDRESS --value 0.1ether \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY

# Or send via MetaMask to the controller address
```

## 5️⃣ Run

```bash
# Start monitoring
npm run monitor

# Or run in background with PM2
pm2 start scripts/monitor.js --name auto-mine-franchiser
pm2 save
```

## 📊 Check Status

```bash
npm run status
```

Output:
```
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

## 🎯 Update Target Rig (Owner Only)

```bash
# Switch to a different Franchiser Rig
cast send $CONTROLLER_ADDRESS \
  "updateTargetRig(address)" \
  0xNEW_RIG_ADDRESS \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

## 🎛️ Update Config (Owner Only)

```bash
# Example: Change max price to 0.002 ETH
cast send $CONTROLLER_ADDRESS \
  "updateConfig(uint256,uint256,uint256,uint256,bool,uint256,uint256)" \
  2000000000000000 1000 100000000000000000000 1000000000000000000 true 300 10 \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

## 🛑 Emergency Stop

```bash
cast send $CONTROLLER_ADDRESS "emergencyStop()" \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

## 💰 Withdraw Profits

```bash
# Withdraw all ETH
cast send $CONTROLLER_ADDRESS "withdrawETH(address,uint256)" \
  $OWNER_ADDRESS 0 \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY

# Withdraw minted tokens
cast send $CONTROLLER_ADDRESS "withdrawTokens(address,address,uint256)" \
  $TOKEN_ADDRESS $OWNER_ADDRESS 0 \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

## 📈 Monitor Logs

```bash
# If using PM2
pm2 logs auto-mine-franchiser

# If using systemd
journalctl -u auto-mine-franchiser -f
```

## ⚠️ Troubleshooting

**"Insufficient ETH balance"**  
→ Fund the controller with more ETH

**"Price too high"**  
→ Adjust `MAX_PRICE_PER_TOKEN` or wait for better price

**"Cooldown active"**  
→ Normal - bot enforces cooldown between mints

**"Gas price too high"**  
→ Increase `MAX_GAS_PRICE` in config or wait

**"TARGET_RIG not set"**  
→ Add TARGET_RIG to your .env file

## 📚 Full Documentation

See [README.md](./README.md) for complete documentation.

## 🆘 Support

- GitHub Issues: https://github.com/cruller-agent/auto-mine-franchiser/issues
- Twitter: @cruller_donut

---

Happy mining! ⚙️
