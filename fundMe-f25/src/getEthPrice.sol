// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Eth/Usd : 0x694AA1769357215DE4FAC081bf1f309aDC325306

library getEthPrice {
    function getPrice(AggregatorV3Interface dataFeed) public view returns (uint256) {
        (, int256 answer,,,) = dataFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface dataFeed) public view returns (uint256) {
        uint256 ethPric = getPrice(dataFeed);
        return (ethAmount * ethPric) / 1e18;
    }
}
