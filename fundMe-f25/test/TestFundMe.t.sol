// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract TestFundMe is Test {
    address USER = makeAddr("user");

    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 5 ether}();
        _;
    }

    function testMinBalanceIsFive() public view {
        assertEq(fundMe.s_minValue(), 5e18);
    }

    function testOwnerAddress() public view {
        assertEq(fundMe.s_owner(), msg.sender);
    }

    // function testAddresssToAmountFunded() public funded{
    //     assertEq(fundMe.getAddressToAmountFunded(USER),1 ether);
    // }

    function testErrorMinValue() public {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.fund();
    }

    function testWithdrawal() public funded {
        // vm.expectRevert();
        vm.prank(msg.sender);
        fundMe.withdrawal();
    }

    // function testFallback() public {
    //     vm.prank(USER);
    //     (bool success,) = payable(address(fundMe)).call{value:1 ether}("");
    //     assertTrue(success);
    //     assertEq(fundMe.getAddressToAmountFunded(USER),1 ether);
    // }

    function testFundersArray() public funded {
        assertEq(fundMe.getFunders(0), USER);
    }

    function testWithdrawalWithSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdrawal();
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }
}
