// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {BasicToken} from "src/BasicToken.sol";

contract DeployBasicToken is Script {
    uint256 public constant INITIAL_SUPPLY = 10000 ether;

    function Deploy() public returns (BasicToken) {
        vm.startBroadcast();
        BasicToken basicToken = new BasicToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return (basicToken);
    }

    function run() external returns (BasicToken) {
        return Deploy();
    }
}
