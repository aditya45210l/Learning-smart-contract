//SPDX-License-Identifier:MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockAggregatorV3.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    NetworkConfig public sepoliaNetworkConfig;
    NetworkConfig public anvilNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            sepoliaNetworkConfig = getSepoliaEthConfig();
            activeNetworkConfig = sepoliaNetworkConfig;
        } else {

            anvilNetworkConfig = getAnvilEthConfig();
            activeNetworkConfig = anvilNetworkConfig;
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (anvilNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        MockV3Aggregator mockPriceFeed;
        vm.startBroadcast();
        mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
