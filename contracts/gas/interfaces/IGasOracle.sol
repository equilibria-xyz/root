// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { UFixed18 } from "../../number/types/UFixed18.sol";

interface IGasOracle {
    function COMPUTE_GAS() external view returns (UFixed18);
    function CALLDATA_GAS() external view returns (UFixed18);
    function FEED() external view returns (AggregatorV3Interface);
    function FEED_OFFSET() external view returns (int256);

    /// @notice Computes the reward of a transaction
    /// @param value The ether value of the transaction in addition to the gas cost rewarded
    /// @return The reward of the transaction
    function cost(uint256 value) external view returns (UFixed18);
}
