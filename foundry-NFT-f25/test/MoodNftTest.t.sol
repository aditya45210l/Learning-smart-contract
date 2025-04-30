// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "src/MoodNft.sol";
import {Utils} from "./Utils/Utils.sol";

contract MoodNftTest is Test, Utils {
    MoodNft moodNft;
    address USER = makeAddr("user");

    function setUp() external {
        vm.startBroadcast();
        moodNft = new MoodNft(HAPPY_URI, SAD_SVG);
        vm.stopBroadcast();
        vm.deal(USER, 1 ether);
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "MoodNft";
        string memory actualName = moodNft.name();
        assert(keccak256(abi.encodePacked(expectedName)) == keccak256(abi.encodePacked(actualName)));
    }

    // function testTokenUriIsCorrect() public{
    //     string memory expectedTokenUri = string.concat("data:application/json;base64,",HAPPY_URI);
    //     vm.prank(USER);
    //     moodNft.mintNft();
    //     string memory actualTokenUri = moodNft.tokenURI(0);
    //     console.log("expectedTokenUri:",expectedTokenUri);
    //     console.log("actualTokenUri:",actualTokenUri);
    //     assert(keccak256(abi.encodePacked(expectedTokenUri))  == keccak256(abi.encodePacked(actualTokenUri)));
    // }
    function testViewTokenUri() public {
        vm.prank(USER);
        moodNft.mintNft();
        string memory actualTokenUri = moodNft.tokenURI(0);

        console.log("actualTokenUri:", actualTokenUri);
    }
}
