// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test,console} from "forge-std/Test.sol";
import {BasicToken} from "src/BasicToken.sol";
import {DeployBasicToken} from "script/DeployBasicToken.s.sol";

contract BasicTokenTest is Test {
    // State variables
    uint256 public constant INITIAL_SUPPLY = 10000 ether;
    address public ADITYA = makeAddr("aditya");
    address public MUSKAN = makeAddr("muskan");
    uint256 public constant AMOUNT = 10 ether;

    BasicToken public basicToken;
    DeployBasicToken public deployBasicToken;

    function setUp() public{
        vm.deal(ADITYA, 100 ether);
        vm.deal(MUSKAN, 100 ether);
        deployBasicToken = new DeployBasicToken();
        basicToken = deployBasicToken.Deploy();

        // basicToken.transfer(ADITYA,AMOUNT);
        console.log("ADITYA BALANCE: ", basicToken.balanceOf(msg.sender));
        vm.prank(msg.sender);
        basicToken.transfer(ADITYA, INITIAL_SUPPLY);
    }

    function testAllowence() public{
        uint256 initialAllowence = 1000 ether;

        //aditya approve muskan to spend 1000 tokens on his behalf
        vm.prank(ADITYA);
        basicToken.approve(MUSKAN,initialAllowence);
        //check the allowence
        uint256 starting = 100 ether;

        vm.prank(MUSKAN);
        basicToken.transferFrom(ADITYA,MUSKAN,starting);
        assertEq(basicToken.balanceOf(MUSKAN),starting);
        assertEq(basicToken.balanceOf(ADITYA), INITIAL_SUPPLY - starting);

        
    }

}
