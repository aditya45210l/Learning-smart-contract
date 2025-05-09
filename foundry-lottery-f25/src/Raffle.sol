// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
//lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev

import {VRFConsumerBaseV2Plus} from "@chainlink/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle contract
 * @author Aditya
 * @notice This contract is for creating a simple raffle  lotteries,
 * @dev This implements Chainlink VRF to select a random winner,
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /**
     * Errors
     */
    error Raffle__NotEnoughEthSent();
    error Raffle__TransferFail();
    error Raffle__RaffleClosed();
    error Raffle__UpkeepNotNeeded(uint256 balance, uint256 PlayerLength, uint256 raffleState);
    /**
     * Type Declaration
     */

    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /**
     * State variables
     */
    // immutable variables
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    uint256 private s_subscriptionId;
    bytes32 private s_gasLane;
    address payable s_recentWinner;
    uint16 private constant s_requestConfirmations = 3;
    uint32 private constant NUM_WORDS = 1;
    RaffleState private s_RaffleState;

    /**
     * Events
     */
    event Raffle__playerEnterd(address indexed player);
    event Raffle__winnerPicked(address indexed);
    event Raffle__RequestRandomWord(uint256 indexed);

    //** Cunstructor */
    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        uint256 subscriptionId
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_gasLane = gasLane;
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_callbackGasLimit = callbackGasLimit;
        s_lastTimeStamp = block.timestamp;
        s_subscriptionId = subscriptionId;

        s_RaffleState = RaffleState.OPEN;
    }

    //** Functions */

    // This funciton help player to Enter the raffle
    function enterRaffle() external payable {
        /**
         * @dev checking player must send ETH more then the entranceFee which was set by lottery owner!
         */
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        if (s_RaffleState != RaffleState.OPEN) {
            revert Raffle__RaffleClosed();
        }
        /**
         * @dev Storing contrubiters address
         */
        s_players.push(payable(msg.sender));
        /**
         * @dev Emiting an event when ever new palyer was enter in lottery
         */
        emit Raffle__playerEnterd(msg.sender);
    }

    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        // check enough time was passed
        bool timeHasPassed = ((block.timestamp - s_lastTimeStamp) >= i_interval);
        // check enough balance was in wallet
        bool enoughEth = address(this).balance > 0;
        // check atleast one was entered in raffle
        bool hasPlayers = s_players.length > 0;
        // check raffle was open
        bool isOpen = s_RaffleState == RaffleState.OPEN;
        // if all are true then set upkeepNeeded value to = true & return also

        upkeepNeeded = timeHasPassed && enoughEth && hasPlayers && isOpen;
        return (upkeepNeeded, "");
    }

    function performUpkeep(bytes calldata /* performData */ ) external {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_RaffleState));
        }

        s_RaffleState = RaffleState.CALCULATING;
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_gasLane,
                subId: s_subscriptionId,
                requestConfirmations: s_requestConfirmations,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
            })
        );
        emit Raffle__RequestRandomWord(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        s_recentWinner = s_players[indexOfWinner];
        (bool success,) = s_recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFail();
        }
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit Raffle__winnerPicked(s_recentWinner);
    }
    

    /**
     * Getters Functions
     */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_RaffleState;
    }

    function getPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getRecentWinner() external view returns (address){

        return s_recentWinner;
    }
}
