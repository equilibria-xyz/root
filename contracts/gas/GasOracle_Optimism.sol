// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { UFixed18, UFixed18Lib } from "../number/types/UFixed18.sol";
import { Fixed18Lib } from "../number/types/Fixed18.sol";
import { GasOracle } from "./GasOracle.sol";

interface OptGasInfo {
    function getL1GasUsed(bytes memory) external view returns (uint256);
    function l1BaseFee() external view returns (uint256);
    function baseFeeScalar() external view returns (uint256);
    function blobBaseFee() external view returns (uint256);
    function blobBaseFeeScalar() external view returns (uint256);
    function decimals() external view returns (uint256);
}

contract GasOracle_Optimism is GasOracle {
    OptGasInfo constant OPT_GAS = OptGasInfo(0x420000000000000000000000000000000000000F);
    uint256 public constant OPT_BASE_FEE_MULTIPLIER = 16;

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

    // https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/GasPriceOracle.sol#L138
    // applicable to only the ecotone hardfork
    function _calldataBaseFee() internal override view returns (uint256) {
        return (
            OPT_BASE_FEE_MULTIPLIER * OPT_GAS.baseFeeScalar() * OPT_GAS.l1BaseFee() +
            OPT_GAS.blobBaseFeeScalar() * OPT_GAS.blobBaseFee()
        ) / (OPT_BASE_FEE_MULTIPLIER * 10 ** OPT_GAS.decimals());
    }
}
