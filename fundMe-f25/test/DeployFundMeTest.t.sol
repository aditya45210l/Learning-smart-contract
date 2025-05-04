// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundMe} from "src/FundMe.sol";

contract DeployFundMeTest is Test{
    DeployFundMe deployFundMe;
    FundMe fundMe;
    function setUp() public {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testSepoliaAddressORAnvilPriceFeed() public {
        
    }
}