// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConvertor {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI

        (, int256 price, , , ) = priceFeed.latestRoundData();
        //  2000.00000000 8 decimal places
        //  2000.00000000 * 1e10 to match up with the value which is 18 decimal places

        return uint256(price * 1e10);
    }

    function getConvertionRate(
        uint256 ammount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);

        uint256 ethAmmounttoUsd = (ethPrice * ammount) / 1e18;
        return ethAmmounttoUsd;
    }
}
