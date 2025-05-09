// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract TimeLockedWallet {
    /**
     * Errors
     */
    error TimeLockedWallet__ValueIsNotBeZero();
    // error TimeLockedWallet__UnlockTimeMustBeInFuture();
    error TimeLockedWallet__NotOwner(address ownerAddress, address callerAddress);
    error TimeLockedWallet__VaultNotExist();
    error TimeLockedWallet__EnoughTimeNotPass(uint256 lockedTime, uint256 unlockTime, uint256 pendingtime);
    error TimeLockedWallet__UserAllReadyWithdraw();
    error TimeLockedWallet__FailToTransferLockedAmount(bytes data);

    /**
     * Events
     */
    event LockCreated(address indexed owner, uint256 indexed amount, uint256 unlockDate);

    event TimeLockedWallet__UserSuccesfullyWithdrawAmountFromVault(
        address indexed User, uint256 indexed withdrawAmount
    );

    /**
     * Type Dicliration
     */
    struct UserVault {
        address payable owner;
        uint256 unlockTime;
        uint256 startTime;
        bool withdraw;
        uint256 id;
        uint256 lockedAmount;
        bool isExist;
    }

    /**
     * State Variables
     */
    uint256 private counter;
    address private immutable ContractOwner;

    constructor() {
        ContractOwner = msg.sender;
        counter = 0;
    }

    /**
     * Mappings
     */
    mapping(uint256 _id => UserVault userVault) private _idToUserVault;
    mapping(address user => uint256[] vaultIdList) private _addressToValutIdList;

    /**
     * Functions
     */
    function dayToSecond(uint256 _days) internal pure returns (uint256) {
        return _days * 86400;
    }

    function CreateLock(uint256 lockDurationInSeconds) external payable {
        if (msg.value == 0) {
            revert TimeLockedWallet__ValueIsNotBeZero();
        }

        _idToUserVault[counter] = UserVault({
            owner: payable(msg.sender),
            unlockTime: block.timestamp + dayToSecond(lockDurationInSeconds),
            startTime: block.timestamp,
            withdraw: false,
            id: counter,
            lockedAmount: msg.value,
            isExist: true
        });
        _addressToValutIdList[msg.sender].push(counter);
        counter++;
        emit LockCreated(msg.sender, msg.value, dayToSecond(lockDurationInSeconds));
    }

    function Withdraw(uint256 _id) public {
        if (!_idToUserVault[_id].isExist) {
            revert TimeLockedWallet__VaultNotExist();
        }

        if (address(msg.sender) != _idToUserVault[_id].owner) {
            revert TimeLockedWallet__NotOwner(_idToUserVault[_id].owner, msg.sender);
        }
        if (block.timestamp < _idToUserVault[_id].unlockTime) {
            revert TimeLockedWallet__EnoughTimeNotPass(
                _idToUserVault[_id].startTime,
                _idToUserVault[_id].unlockTime,
                block.timestamp - _idToUserVault[_id].unlockTime
            );
        }
        if (_idToUserVault[_id].withdraw) {
            revert TimeLockedWallet__UserAllReadyWithdraw();
        }

        (bool success, bytes memory data) =
            (_idToUserVault[_id].owner).call{value: _idToUserVault[_id].lockedAmount}("");

        if (success) {
            emit TimeLockedWallet__UserSuccesfullyWithdrawAmountFromVault(
                _idToUserVault[_id].owner, _idToUserVault[_id].lockedAmount
            );
        } else {
            revert TimeLockedWallet__FailToTransferLockedAmount(data);
        }
    }

    /**
     * View Getter Functions
     */
    function getVaultById(uint256 _id) public view returns (UserVault memory) {
        return _idToUserVault[_id];
    }
}
