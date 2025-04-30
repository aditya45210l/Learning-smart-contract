// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script,console} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64}  from "@openzeppelin/contracts/utils/Base64.sol";
// import {happy} from "../images/happy.svg";

contract DeployMoodNft is Script {
    MoodNft moodNft;
    function run() external returns(MoodNft) {
        string memory happySvg = vm.readFile("./images/happy.svg");
        string memory sadSvg = vm.readFile("./images/sad.svg");

        vm.startBroadcast();
        moodNft = new MoodNft(svgToImageURI(happySvg),svgToImageURI(sadSvg));
        vm.stopBroadcast();

        return moodNft;
    }


    function svgToImageURI(string memory svg) public pure returns(string memory ) {
        string memory baseUrl = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseUrl,svgBase64Encoded));
    }
}
