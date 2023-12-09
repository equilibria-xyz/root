// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./Kept.sol";

interface OptGasInfo {
    function getL1GasUsed(bytes memory) external view returns (uint256);
    function l1BaseFee() external view returns (uint256);
    function scalar() external view returns (uint256);
    function decimals() external view returns (uint256);
}

/// @dev Optimism Kept implementation
abstract contract Kept_Optimism is Kept {
    // https://community.optimism.io/docs/developers/build/transaction-fees/#the-l1-data-fee
    OptGasInfo constant OPT_GAS = OptGasInfo(0x420000000000000000000000000000000000000F);

    // https://community.optimism.io/docs/developers/build/transaction-fees/#the-l1-data-fee
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
            OPT_GAS.l1BaseFee() * OPT_GAS.scalar() / (10 ** OPT_GAS.decimals())
        );
    }
}
