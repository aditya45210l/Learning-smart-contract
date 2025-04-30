// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";
import {DeployCrowdFunding} from "../../script/DeployCrowdFunding.s.sol";

contract CrowdFundingTest is Test {
    CrowdFunding public crowdFunding;
    address public ProjectOwner = makeAddr("ProjectOwner");
    address public User = makeAddr("User");

    function setUp() public {
        DeployCrowdFunding deployCrowdFunding = new DeployCrowdFunding();
        crowdFunding = deployCrowdFunding.DeployContract();
        vm.deal(ProjectOwner, 1 ether);
    }

    modifier createProject() {
        // Create a project
        vm.prank(ProjectOwner);
        crowdFunding.CreateProject(
            "Test Protocol",
            "Test Title",
            "Test Description",
            100 ether,
            1 ether,
            block.timestamp,
            block.timestamp + 1 days
        );
        _;
    }

    modifier fundProject() {
        vm.prank(ProjectOwner);
        crowdFunding.fundToProject{value: 1 ether}(1);
        _;
    }

    function testCheckOwner() public createProject {
        assertEq(crowdFunding.getProjectDetails(1).projectOwner, ProjectOwner);
    }

    function testProjectInputs() public createProject {
        vm.prank(ProjectOwner);
        crowdFunding.fundToProject{value: 1 ether}(1);
        CrowdFunding.Projects memory project = crowdFunding.getProjectDetails(1);
        assertEq(project.protocolName, "Test Protocol");
        assertEq(project.title, "Test Title");
        assertEq(project.description, "Test Description");
        assertEq(project.totalFundingAmount, 100 ether);
        assertEq(project.minAmountToFund, 1 ether);
        assertEq(project.projectOwner, ProjectOwner);
        assertEq(project.startDate, block.timestamp);
        assertEq(project.endDate, block.timestamp + 1 days);
        assertEq(project.isActive, true);
        assertEq(project.exists, true);
        assertEq(project.funders.length, 1);
        assertEq(address(crowdFunding).balance, 1 ether);
    }

    function testCheckErrorAreWorking() public createProject {
        // check 1 done
        vm.prank(ProjectOwner);
        vm.expectRevert(CrowdFunding.CrowdFunding__InsufficentFund.selector);
        crowdFunding.fundToProject{value: 0}(1);

        // check 2 done
        vm.prank(ProjectOwner);
        vm.expectRevert();
        crowdFunding.fundToProject{value: 1 ether}(234);

        //check 3 done
        vm.prank(ProjectOwner);
        crowdFunding.CreateProject(
            "Test Protocol",
            "Test Title",
            "Test Description",
            100 ether,
            1 ether,
            block.timestamp + 1 days,
            block.timestamp + 2 days
        );

        vm.prank(ProjectOwner);
        vm.expectRevert(CrowdFunding.CrowdFunding__ProjectIsNotActive.selector);
        crowdFunding.fundToProject{value: 1 ether}(2);

        //check 4 done
        vm.prank(ProjectOwner);
        vm.expectRevert(CrowdFunding.CrowdFunding__MinFundingAmountIsHigherThenTotalFundingAmount.selector);
        crowdFunding.CreateProject(
            "Test Protocol",
            "Test Title",
            "Test Description",
            10 ether,
            100 ether,
            block.timestamp,
            block.timestamp + 1 days
        );

        //check 5 done
        vm.expectRevert(CrowdFunding.CrowdFunding__EndingDateIsLessThanStartDate.selector);
        crowdFunding.CreateProject(
            "Test Protocol",
            "Test Title",
            "Test Description",
            100 ether,
            1 ether,
            block.timestamp + 2 days,
            block.timestamp + 1 days
        );
    }

    function testRightAmountRecodedWhenUserFunds() public createProject {
        hoax(User, 100 ether);

        crowdFunding.fundToProject{value: 1 ether}(1);
        assertEq(crowdFunding.getProjectDetails(1).currentBalance, 1 ether);
        uint256 fundedAmount = crowdFunding.getAmountFundedByUser(1, User);
        assertEq(fundedAmount, 1 ether);
    }

    function testFuingbalanceWasRecoded() public createProject{
        hoax(User, 100 ether);
        crowdFunding.fundToProject{value: 1 ether}(1);

        for(uint256 i = 1; i <=10 ; i++){
            address user = address(uint160(i));
            hoax(user, 100 ether);
            crowdFunding.fundToProject{value: 1 ether}(1);
        }

        console.log(address(crowdFunding).balance);
        console.log(crowdFunding.getProjectDetails(1).currentBalance);
    }

    function testProjectOwnerCanWithdraw() public createProject {
        hoax(User, 1000 ether);
        crowdFunding.fundToProject{value:5 ether}(1);

        vm.prank(ProjectOwner);
        vm.expectRevert(CrowdFunding.CrowdFunding__FundedBalanceIsLowerThanTotalBalanceSetByOwner.selector);
        crowdFunding.withdrawalFund(1);

        vm.prank(User);
        crowdFunding.fundToProject{value:100 ether}(1);

        vm.prank(ProjectOwner);
        crowdFunding.withdrawalFund(1);

        
    }

    function testWithdrawFundCreditToOwner() public createProject{
        hoax(User, 1000 ether);
        crowdFunding.fundToProject{value:100 ether}(1);

        uint256 previosBalance = address(ProjectOwner).balance;

        uint256 projectBalance = crowdFunding.getProjectDetails(1).currentBalance;

        vm.prank(ProjectOwner);
        crowdFunding.withdrawalFund(1);

        assertEq(address(ProjectOwner).balance, previosBalance + projectBalance);


    }

}

// function testFundToProject() public {
//     // Create a project
//     crowdFunding.CreateProject("Test Protocol", "Test Title", "Test Description", 100 ether, 10 ether, block.timestamp, block.timestamp + 1 days);

//     // Fund the project
//     uint256 projectId = 1;
//     uint256 fundingAmount = 20 ether;
//     crowdFunding.fundToProject{value: fundingAmount}(projectId);

//     // Check the project's current balance
//     CrowdFunding.Projects memory project = crowdFunding.getProjectDetails(projectId);
//     assertEq(project.currentBalance, fundingAmount);
// }
