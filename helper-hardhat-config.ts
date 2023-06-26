import { SEPOLIA_PRICEFEED_ADDRESS } from "./constants";

/**
 * The list of blockchains which are local and we want to use for development
 */
const developmentChains = ["localhost", "hardhat", "ganache"];

/**
 * Configuration for each network
 */
const networksConfig = {
  sepolia: {
    name: "Sepolia",
    chainId: 11155111,
    priceFeedAddress: SEPOLIA_PRICEFEED_ADDRESS,
  },
};

export { developmentChains, networksConfig };
