// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { UFixed18, UFixed18Lib } from "../number/types/UFixed18.sol";
import { Fixed18Lib } from "../number/types/Fixed18.sol";
import { IGasOracle } from "./interfaces/IGasOracle.sol";

/// @title GasOracle
/// @notice Standalone gas oracle for externally computing keeper rewards based on ether gas costs
contract GasOracle is IGasOracle {
    /// @notice The total compute gas rewarded
    UFixed18 public immutable COMPUTE_GAS;

    /// @notice The total calldata gas rewarded
    UFixed18 public immutable CALLDATA_GAS;

    /// @notice Chainlink ETH-Token feed, where cost is expressed in terms of Token
    AggregatorV3Interface public immutable FEED;

    /// @notice The precomputed offset of the Chainlink feed (10 ^ decimals)
    int256 public immutable FEED_OFFSET;

    constructor(
        AggregatorV3Interface feed,
        uint256 decimals,
        uint256 computeGas,
        UFixed18 computeMultiplier,
        uint256 computeBase,
        uint256 calldataGas,
        UFixed18 calldataMultiplier,
        uint256 calldataBase
    ) {
        FEED = feed;
        FEED_OFFSET = int256(10 ** decimals);
        COMPUTE_GAS = _precompute(computeGas, computeMultiplier, computeBase);
        CALLDATA_GAS = _precompute(calldataGas, calldataMultiplier, calldataBase);
    }

   /// @inheritdoc IGasOracle
    function cost(uint256 value) external view returns (UFixed18) {
        (UFixed18 baseFee, UFixed18 calldataFee) =
            (UFixed18.wrap(block.basefee).mul(COMPUTE_GAS), UFixed18.wrap(_calldataBaseFee()).mul(CALLDATA_GAS));

        return UFixed18.wrap(value).add(baseFee).add(calldataFee).mul(_etherPrice());
    }

    /// @notice Precomputes the total rewarded gas cost
    /// @param gas The applicable gas cost
    /// @param multiplier The reward multiplier to apply to the gas cost
    /// @param base The base gas reward to add on to the gas cost
    /// @return The total rewarded gas cost
    function _precompute(uint256 gas, UFixed18 multiplier, uint256 base) private pure returns (UFixed18) {
        return UFixed18Lib.from(gas).mul(multiplier).add(UFixed18Lib.from(base));
    }

    /// @notice Returns the price of ether in terms of the underlying token
    /// @return The price of ether in terms of the underlyingtoken
    function _etherPrice() private view returns (UFixed18) {
        (, int256 answer, , ,) = FEED.latestRoundData();
        return UFixed18Lib.from(Fixed18Lib.ratio(answer, FEED_OFFSET));
    }

    /// @notice Returns the base fee of the calldata
    /// @dev Can be overridden to provide a non-zero calldata base fee for L2 implementations
    /// @return The base fee of the calldata
    function _calldataBaseFee() internal virtual view returns (uint256) { return 0; }
}
