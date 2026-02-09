#!/usr/bin/env node
/**
 * Check controller status and display current configuration
 */

const { ethers } = require("ethers");
const dotenv = require("dotenv");

dotenv.config();

const RPC_URL = process.env.BASE_RPC_URL || "https://mainnet.base.org";
const CONTROLLER_ADDRESS = process.env.CONTROLLER_ADDRESS;

const CONTROLLER_ABI = [
  "function getMiningStatus() view returns (bool isEnabled, bool canMintNow, uint256 currentPrice, uint256 nextMintTime, uint256 nextTimeBasedMintTime, uint256 quoteBalance, uint256 currentEpochId, bool priceConditionMet, bool timeConditionMet)",
  "function config() view returns (uint256 maxMiningPrice, uint256 minProfitMargin, uint256 maxMintAmount, uint256 minMintAmount, bool autoMiningEnabled, uint256 cooldownPeriod, uint256 maxGasPrice, uint256 timeBasedMintPeriod)",
  "function checkProfitability() view returns (bool isProfitable, uint256 currentPrice, uint256 recommendedAmount, uint256 reason)",
  "function lastMintTimestamp() view returns (uint256)",
  "function targetRig() view returns (address)",
];

const RIG_ABI = [
  "function quote() view returns (address)"
];

const ERC20_ABI = [
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)"
];

async function main() {
  if (!CONTROLLER_ADDRESS) {
    console.error("❌ CONTROLLER_ADDRESS not set in .env");
    process.exit(1);
  }

  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const controller = new ethers.Contract(CONTROLLER_ADDRESS, CONTROLLER_ABI, provider);

  console.log("⚙️  Auto-Mine Franchiser Status\n");
  console.log(`📍 Controller: ${CONTROLLER_ADDRESS}`);

  try {
    // Get rig address
    const targetRig = await controller.targetRig();
    console.log(`🎯 Target Rig: ${targetRig}`);
    
    // Get quote token info
    let quoteSymbol = "???";
    let quoteDecimals = 18;
    try {
      const rig = new ethers.Contract(targetRig, RIG_ABI, provider);
      const quoteTokenAddress = await rig.quote();
      const quoteToken = new ethers.Contract(quoteTokenAddress, ERC20_ABI, provider);
      quoteSymbol = await quoteToken.symbol();
      quoteDecimals = await quoteToken.decimals();
      console.log(`💰 Quote Token: ${quoteSymbol} (${quoteTokenAddress})`);
    } catch (error) {
      console.log(`💰 Quote Token: unable to fetch`);
    }
    console.log("");

    // Get configuration
    const config = await controller.config();
    console.log("⚙️  Configuration:");
    console.log(`  Max Mining Price: ${ethers.formatUnits(config.maxMiningPrice, quoteDecimals)} ${quoteSymbol} per mine`);
    console.log(`  Min Profit: ${config.minProfitMargin / 100}%`);
    console.log(`  Mint Range: ${ethers.formatEther(config.minMintAmount)} - ${ethers.formatEther(config.maxMintAmount)} tokens`);
    console.log(`  Auto Mining: ${config.autoMiningEnabled ? "✅ ENABLED" : "❌ DISABLED"}`);
    console.log(`  Cooldown: ${config.cooldownPeriod}s`);
    console.log(`  Max Gas: ${config.maxGasPrice} gwei`);
    console.log(`  Time-Based Mint Period: ${config.timeBasedMintPeriod}s\n`);

    // Get mining status
    const status = await controller.getMiningStatus();
    console.log("📊 Mining Status:");
    console.log(`  Current Price: ${ethers.formatUnits(status.currentPrice, quoteDecimals)} ${quoteSymbol}`);
    console.log(`  Epoch: ${status.currentEpochId}`);
    console.log(`  Quote Balance: ${ethers.formatUnits(status.quoteBalance, quoteDecimals)} ${quoteSymbol}`);
    console.log(`  Can Mint Now: ${status.canMintNow ? "✅ YES" : "❌ NO"}`);
    console.log(`  Price Condition: ${status.priceConditionMet ? "✅ MET" : "❌ NOT MET"}`);
    console.log(`  Time Condition: ${status.timeConditionMet ? "✅ MET" : "❌ NOT MET"}`);
    
    if (!status.canMintNow && status.nextMintTime > 0n) {
      const nextMint = new Date(Number(status.nextMintTime) * 1000);
      const now = new Date();
      const waitTime = Math.max(0, Math.floor((nextMint - now) / 1000));
      console.log(`  Next Mine (Cooldown): ${nextMint.toLocaleString()} (in ${waitTime}s)`);
    }
    
    if (!status.timeConditionMet && status.nextTimeBasedMintTime > 0n) {
      const nextTimeMint = new Date(Number(status.nextTimeBasedMintTime) * 1000);
      const now = new Date();
      const waitTime = Math.max(0, Math.floor((nextTimeMint - now) / 1000));
      console.log(`  Next Time-Based Mint: ${nextTimeMint.toLocaleString()} (in ${waitTime}s)`);
    }
    console.log("");

    // Check profitability
    const [isProfitable, currentPrice, recommendedAmount, reason] = await controller.checkProfitability();
    const reasonText = reason === 0n ? "Price-based" : reason === 1n ? "Time-based" : "Not profitable";
    console.log("💰 Profitability:");
    console.log(`  Status: ${isProfitable ? "✅ PROFITABLE" : "❌ NOT PROFITABLE"}`);
    console.log(`  Reason: ${reasonText}`);
    console.log(`  Current Price: ${ethers.formatUnits(currentPrice, quoteDecimals)} ${quoteSymbol}`);
    console.log(`  Recommended: ${ethers.formatEther(recommendedAmount)} tokens\n`);

    // Check balance sufficiency
    if (isProfitable) {
      const priceFormatted = ethers.formatUnits(currentPrice, quoteDecimals);
      console.log(`💸 Mine Cost: ${priceFormatted} ${quoteSymbol}`);
      
      const balanceFormatted = ethers.formatUnits(status.quoteBalance, quoteDecimals);
      console.log(`💰 Balance: ${balanceFormatted} ${quoteSymbol}`);
      
      if (status.quoteBalance >= currentPrice) {
        console.log(`✅ Sufficient balance for next mine\n`);
      } else {
        const needed = currentPrice - status.quoteBalance;
        const neededFormatted = ethers.formatUnits(needed, quoteDecimals);
        console.log(`❌ Need ${neededFormatted} more ${quoteSymbol}\n`);
      }
    }

    // Last mine info
    const lastMint = await controller.lastMintTimestamp();
    if (lastMint > 0n) {
      const lastMintDate = new Date(Number(lastMint) * 1000);
      const timeSince = Math.floor((Date.now() - lastMintDate.getTime()) / 1000);
      console.log(`🕒 Last Mine: ${lastMintDate.toLocaleString()} (${timeSince}s ago)`);
    } else {
      console.log(`🕒 Last Mine: Never`);
    }

  } catch (error) {
    console.error("\n❌ Error:", error.message);
    process.exit(1);
  }
}

main();
