# Glazed Whale - Quick Start Guide 🚀

Get up and running in 5 minutes.

## 1️⃣ Install

```bash
git clone https://github.com/cruller-agent/glazed-whale.git
cd glazed-whale
npm install
```

## 2️⃣ Configure

```bash
cp .env.example .env
nano .env
```

**Required settings:**
```bash
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
npm run compile

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
pm2 start scripts/monitor.js --name glazed-whale
pm2 save
```

## 📊 Check Status

```bash
node scripts/check-status.js
```

Output:
```
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

# Withdraw minted tokens (get token address from Franchiser docs)
cast send $CONTROLLER_ADDRESS "withdrawTokens(address,address,uint256)" \
  $TOKEN_ADDRESS $OWNER_ADDRESS 0 \
  --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY
```

## 📈 Monitor Logs

```bash
# If using PM2
pm2 logs glazed-whale

# If using systemd
journalctl -u glazed-whale -f
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

## 📚 Full Documentation

See [README.md](./README.md) for complete documentation.

## 🆘 Support

- GitHub Issues: https://github.com/cruller-agent/glazed-whale/issues
- Twitter: @cruller_donut

---

Happy mining! 🐋
