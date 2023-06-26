import "dotenv/config";

export const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || "";
export const SEPOLIA_ACCOUNT_PRIVATE_KEY =
  process.env.SEPOLIA_ACCOUNT_PRIVATE_KEY || "0x";
export const SEPOLIA_PRICEFEED_ADDRESS =
  process.env.SEPOLIA_PRICEFEED_ADDRESS || "";

export const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";
export const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "";

export const LOCAL_ACCOUNT_PRIVATE_KEY =
  process.env.LOCAL_ACCOUNT_PRIVATE_KEY || "0x";
