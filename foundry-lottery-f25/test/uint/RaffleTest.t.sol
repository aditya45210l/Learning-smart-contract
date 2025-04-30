// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test,console} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Raffle} from "src/Raffle.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {
    event Raffle__playerEnterd(address indexed player);
    event Raffle__winnerPicked(address indexed);

    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    address PLAYER = makeAddr("player");

    

    function setUp() public {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployContract();
        vm.deal(PLAYER, 100 ether);
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;
    }

    modifier prank() {
        vm.prank(PLAYER);
        _;
    }
    modifier enterd(){
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
         _;
    }

    function testRaffleWasOpen() public prank {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testPlayerCantEnterWithoutPayingFees() public prank {
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnterd() public prank {
        raffle.enterRaffle{value: 1 ether}();
        assert(raffle.getPlayer(0) == PLAYER);
    }

    function testRaffleEnterEventWasEmitProperly() public prank {
        vm.expectEmit(true, false, false, false, address(raffle));
        emit Raffle__playerEnterd(PLAYER);

        raffle.enterRaffle{value: 1 ether}();
    }

    function testDontAllowPlayerToEnterWhileRaffle() public prank {
        raffle.enterRaffle{value: 1 ether}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleClosed.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: 1 ether}();
    }
    function testCheckUpKeepReturnsFasleIfHasNotBalance() public {
        vm.warp(block.timestamp + interval + 1 ) ;
        vm.roll(block.number + 1);

        (bool upkeepNeeded,) = raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }
    function testCheckUpkeepReturnsFalseIfRaffleIsNotOpen() public prank {
        raffle.enterRaffle{value:entranceFee}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert( raffleState == Raffle.RaffleState.CALCULATING);
    }

    function testPerformUpKeepUpdatesRaffleStateAndRequestId() public prank{
        raffle.enterRaffle{value:entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);


        vm.recordLogs();
        raffle.performUpkeep("");
         
         Vm.Log[] memory entries = vm.getRecordedLogs();

         bytes32 requestId = entries[1].topics[1];


        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);
    }

    function testOneBigTest () public enterd {
        uint256 additionalEntries = 4;
        uint256 startingIndex = 1;
        for(uint256 i = startingIndex;i  <additionalEntries; i++ ){
            address player = address(uint160(i));
            hoax(player, 1 ether);
            raffle.enterRaffle{value:entranceFee}();
        }
        uint256 startingTimeStamp = raffle.getLastTimeStamp();
        vm.recordLogs();

        raffle.performUpkeep('');

        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId),address(raffle));

        uint256 endingTimeStamp = raffle.getLastTimeStamp();

        uint256 prize = entranceFee * (additionalEntries + 1);
        assert(endingTimeStamp > startingTimeStamp);
        assert(raffle.getRecentWinner() != address(0));
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        // assert(raffle.getRecentWinner().balance == startingBalance + prize);


    }
}
