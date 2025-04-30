//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {getEthPrice} from "./getEthPrice.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__userNotOwner();
//0x137cA3B75C84ecfB75fC1cb60FCc421319721896

contract FundMe {
    using getEthPrice for uint256;

    uint256 public constant s_minValue = 5e18; // Test done
    address public s_owner; // Test done
    address[] public funders;
    AggregatorV3Interface priceFeed;
    mapping(address => uint256) public s_addressToAmountFunded;

    constructor(address dataFeed) {
        s_owner = msg.sender;
        priceFeed = AggregatorV3Interface(dataFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(priceFeed) >= s_minValue, "Value less than min value!");
        funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = s_addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdrawal() public onlyOwner {
        uint256 fundersLength = funders.length;
        for (uint256 i; i < fundersLength; i++) {
            address tempFunder = funders[i];
            s_addressToAmountFunded[tempFunder] = 0;
        }

        funders = new address[](0);

        (bool callSucess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSucess, "call failed!");
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner, FundMe__userNotOwner());
        _;
    }

    receive() external payable {
        fund();
    }

    // fallback() external payable {
    //     fund();
    // }

    // Getter functions
    function getAddressToAmountFunded(address funder) external view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getFunders(uint256 index) external view returns (address) {
        return funders[index];
    }

    function getOwner() external view returns (address) {
        return s_owner;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
