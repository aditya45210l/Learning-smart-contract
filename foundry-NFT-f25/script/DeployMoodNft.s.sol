// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Utils} from "../test/Utils/Utils.sol";

contract DeployMoodNft is Script, Utils {
    function run() external returns (MoodNft) {
        vm.startBroadcast();
        MoodNft moodNft = new MoodNft(HAPPY_URI, SAD_SVG);
        vm.stopBroadcast();
        return moodNft;
    }
}
