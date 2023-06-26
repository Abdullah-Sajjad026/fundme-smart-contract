// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title PriceConverter
 * @author Abdullah-Sajjad026
 * @notice A library to work with prices. It gives the price of ether in usd and also converts ether to usd using Chainlink Price Feeds.
 */
library PriceConverter {
    /**
     * A function to get the price of ether in usd
     * @notice Gets the price of ether in usd
     * @param priceFeedAddress The address of the price feed
     */
    function getEthPriceInUsd(
        address priceFeedAddress
    ) internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * (1 ** 10);
    }

    function convertEthToUsd(
        uint256 ethAmount,
        address priceFeedAddress
    ) internal view returns (uint256) {
        uint256 ethPriceInUsd = getEthPriceInUsd(priceFeedAddress);

        return (ethAmount * ethPriceInUsd) / 1 ** 18;
    }
}
