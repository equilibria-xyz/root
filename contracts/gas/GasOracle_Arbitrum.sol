// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { UFixed18, UFixed18Lib } from "../number/types/UFixed18.sol";
import { Fixed18Lib } from "../number/types/Fixed18.sol";
import { GasOracle } from "./GasOracle.sol";

// https://github.com/OffchainLabs/nitro/blob/v2.0.14/contracts/src/precompiles/ArbGasInfo.sol#L93
interface ArbGasInfo {
    /// @notice Get ArbOS's estimate of the L1 basefee in wei
    function getL1BaseFeeEstimate() external view returns (uint256);
}

contract GasOracle_Arbitrum is GasOracle {
    ArbGasInfo constant ARB_GAS = ArbGasInfo(0x000000000000000000000000000000000000006C);

    constructor(
        AggregatorV3Interface feed,
        uint256 decimals,
        uint256 computeGas,
        UFixed18 computeMultiplier,
        uint256 computeBase,
        uint256 calldataGas,
        UFixed18 calldataMultiplier,
        uint256 calldataBase
    ) GasOracle(feed, decimals, computeGas, computeMultiplier, computeBase, calldataGas, calldataMultiplier, calldataBase) { }

    function _calldataBaseFee() internal override view returns (uint256) { return ARB_GAS.getL1BaseFeeEstimate(); }
}
