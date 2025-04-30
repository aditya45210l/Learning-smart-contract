// SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";

contract DeployCrowdFunding is Script {
    CrowdFunding public crowdFunding;
    // this is seperate function to deploy the contract

    function DeployContract() public returns (CrowdFunding) {
        vm.startBroadcast();
        crowdFunding = new CrowdFunding();
        vm.stopBroadcast();
        return (crowdFunding);
    }

    function run() external {
        DeployContract();
    }
}
