// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./Kept.sol";
import { OptGasInfo } from "../../gas/GasOracle_Optimism.sol";

/// @dev Optimism Kept implementation
abstract contract Kept_Optimism is Kept {
    // https://community.optimism.io/docs/developers/build/transaction-fees/#the-l1-data-fee
    OptGasInfo constant OPT_GAS = OptGasInfo(0x420000000000000000000000000000000000000F);
    uint256 public constant OPT_BASE_FEE_MULTIPLIER = 16;

    // https://docs.optimism.io/stack/transactions/fees#ecotone
    // Adds a buffer to the L1 gas used to account for the overhead of the transaction
    function _calldataFee(
        bytes memory applicableCalldata,
        UFixed18 multiplierCalldata,
        uint256 bufferCalldata
    ) internal view virtual override returns (UFixed18) {
        return _fee(
            OPT_GAS.getL1GasUsed(applicableCalldata),
            multiplierCalldata,
            bufferCalldata,
            // https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/GasPriceOracle.sol#L138
            (
                OPT_BASE_FEE_MULTIPLIER * OPT_GAS.baseFeeScalar() * OPT_GAS.l1BaseFee() +
                OPT_GAS.blobBaseFeeScalar() * OPT_GAS.blobBaseFee()
            ) / (OPT_BASE_FEE_MULTIPLIER * 10 ** OPT_GAS.decimals())
        );
    }
}
