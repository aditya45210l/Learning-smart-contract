// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {DeployTimeLockedWallet} from "script/DeployTimeLockedWallet.s.sol";
import {TimeLockedWallet} from "src/TimeLockedWallet.sol";

contract TimeLockedWalletTest is Test {
    DeployTimeLockedWallet deployTimeLockedWallet;
    TimeLockedWallet timeLockedWallet;
    address User = makeAddr("User");

    function setUp() public {
        deployTimeLockedWallet = new DeployTimeLockedWallet();
        timeLockedWallet = deployTimeLockedWallet.deployTimeLockedWallet();
    }

    function testUserCanCreateVaultLock() public {
        hoax(User, 100 ether);
        timeLockedWallet.CreateLock{value: 1 ether}(1);
        TimeLockedWallet.UserVault memory userVault = timeLockedWallet.getVaultById(0);
        console2.log("all logs here!");
        console2.log("owner",userVault.owner);
        console2.log("unlockTime",userVault.unlockTime);
        console2.log("startTime",userVault.startTime);
        console2.log("withdraw",userVault.withdraw);
        console2.log("id",userVault.id);
        console2.log("locked amount",userVault.lockedAmount);
        console2.log(userVault.isExist);

        address owner = userVault.owner;

        assertEq(owner, address(User));
    }
}
