// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {LinkToken} from "../test/Mock/LinkToken.sol";


contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCordinator = helperConfig.getConfig().vrfCoordinator;
        (uint256 subId,) = createSubscription(vrfCordinator);
        return (subId, vrfCordinator);
    }

    function createSubscription(address vrfCordinator) public returns (uint256, address) {
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCordinator).createSubscription();
        vm.stopBroadcast();
        return (subId, vrfCordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();

        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    }

    function fundSubscription(address vrfCoordinator, uint256 subsId, address linkToken) public {
        if (block.chainid == 31337) {
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subsId, 2 ether * 1000);
        } else {
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, 1 ether, abi.encode(subsId));
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumner is Script{

    function addConsumnerUsingConfig(address mostRecentDepoyedContract) public {
        HelperConfig helperConfig = new HelperConfig();
        addConsumer(mostRecentDepoyedContract, helperConfig.getConfig().vrfCoordinator,helperConfig.getConfig().subscriptionId);

    }

    function addConsumer(address mostRecentDepoyedContract, address vrfCoordinator,uint256 subId) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId,mostRecentDepoyedContract);
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentDeployedContract = DevOpsTools.get_most_recent_deployment("Raffle",block.chainid);
        addConsumnerUsingConfig(mostRecentDeployedContract);
    }

}
