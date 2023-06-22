// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConvertor} from "./PriceConvertor.sol";
// error
error FundMe__NotOwner();

contract FundMe {
    using PriceConvertor for uint256;

    uint256 public constant MINIMUM_USD = 5 * 1e18;

    address[] private s_funder;

    mapping(address => uint256) private s_addressToAmmountFunded;

    address private immutable i_owner;

    AggregatorV3Interface public s_priceFeed;

    constructor(address priceAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not Owner!");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function fund() public payable {
        require(
            msg.value.getConvertionRate(s_priceFeed) >= MINIMUM_USD,
            "Not Eough ETH"
        );

        s_funder.push(msg.sender);
        s_addressToAmmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funder.length;
            funderIndex++
        ) {
            address funder_address = s_funder[funderIndex];
            s_addressToAmmountFunded[funder_address] = 0;
        }
        s_funder = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        require(callSuccess, "Call Failed");
    }

    // receive
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * View / Pure Functions (Getters)
     */

    function getAddressToAmmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmmountFunded[fundingAddress];
    }

    function getFunder(uint256 funderIndex) external view returns (address) {
        return s_funder[funderIndex];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
