// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {BasicNft} from "../../src/BasicNft.sol";
import {DeployBasicNft} from "../../script/DeployBasicNft.s.sol";

contract BasicNftTest is Test {
    BasicNft basicNft;
    DeployBasicNft deployBasicNft;

    address USER = makeAddr("user");
    string public constant DOGIE = "ipfs://QmQy4HcwBN9YmrmHxuTYByVgx1Ayu8ZkkawZQqDFLYidpN";
    // string public constant PUG = ""

    function setUp() external {
        deployBasicNft = new DeployBasicNft();
        basicNft = deployBasicNft.run();
        vm.deal(USER, 1 ether);
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "Dogie";
        string memory actualName = basicNft.name();
        assert(keccak256(abi.encodePacked(expectedName)) == keccak256(abi.encodePacked(actualName)));
    }

    function testCanMintAndHaveBalance() public {
        vm.prank(USER);
        basicNft.mintNft(DOGIE);
        uint256 expectedBalance = 1;
        assert(basicNft.balanceOf(USER) == expectedBalance);
        assert(keccak256(abi.encodePacked(DOGIE)) == keccak256(abi.encodePacked(basicNft.tokenURI(0))));
    }
}
