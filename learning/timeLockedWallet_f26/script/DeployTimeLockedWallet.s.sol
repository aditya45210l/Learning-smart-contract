// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {TimeLockedWallet} from "src/TimeLockedWallet.sol";

contract DeployTimeLockedWallet is Script {
    TimeLockedWallet timeLockedWallet;

    function deployTimeLockedWallet() public returns (TimeLockedWallet) {
        vm.startBroadcast();
        timeLockedWallet = new TimeLockedWallet();
        vm.stopBroadcast();
        return timeLockedWallet;
    }

    function run() public returns (TimeLockedWallet) {
        return deployTimeLockedWallet();
    }
}
