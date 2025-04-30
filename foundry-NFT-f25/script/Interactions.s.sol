// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {BasicNft} from "src/BasicNft.sol";
import {DeployBasicNft} from "./DeployBasicNft.s.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MoodNft} from "src/MoodNft.sol";

contract MintBasicNft is Script {
    string private constant URI = "ipfs://QmQy4HcwBN9YmrmHxuTYByVgx1Ayu8ZkkawZQqDFLYidpN";

    function run() external {
        address mostRecentAddress = DevOpsTools.get_most_recent_deployment("BasicNft", block.chainid);

        _mintNft(mostRecentAddress);
    }

    function _mintNft(address mostRecentContract) public {
        vm.startBroadcast();
        BasicNft(mostRecentContract).mintNft(URI);
        vm.stopBroadcast();
    }
}

contract MintMoodNft is Script {
    function run() external {
        address mostRecentAddress = DevOpsTools.get_most_recent_deployment("MoodNft", block.chainid);
        _mintNft(mostRecentAddress);
    }

    function _mintNft(address mostRecentContract) public {
        vm.startBroadcast();
        MoodNft(mostRecentContract).mintNft();
        vm.stopBroadcast();
    }
}

contract flipMoodNft is Script{
    function run() public {
    address mostRecentAddress = DevOpsTools.get_most_recent_deployment("MoodNft", block.chainid);
    uint256 tokenId = 0; // Replace with the actual tokenId you want to flip the mood for
    _flipMood(mostRecentAddress,tokenId);
    
}
function _flipMood(address mostRecentAddress, uint256 tokenId) public {
        vm.startBroadcast();
    MoodNft(mostRecentAddress).filpMood(tokenId);
    vm.stopBroadcast();
}
}