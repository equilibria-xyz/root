// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./Kept.sol";

// https://github.com/OffchainLabs/nitro/blob/v2.0.14/contracts/src/precompiles/ArbGasInfo.sol#L93
interface ArbGasInfo {
    /// @notice Get ArbOS's estimate of the L1 basefee in wei
    function getL1BaseFeeEstimate() external view returns (uint256);
}

/// @dev Arbitrum Kept implementation
abstract contract Kept_Arbitrum is Kept {
    ArbGasInfo constant ARB_GAS = ArbGasInfo(0x000000000000000000000000000000000000006C);
    uint256 public constant ARB_GAS_MULTIPLIER = 16;
    uint256 public constant ARB_FIXED_OVERHEAD = 140;

    // https://docs.arbitrum.io/devs-how-tos/how-to-estimate-gas#breaking-down-the-formula
    // Tx Fee = block.baseFee * l2GasUsed + ArbGasInfo.getL1BaseFeeEstimate() * 16 * (calldataLength + fixedOverhead)
    // Dynamic buffer = (ArbGasInfo.getL1BaseFeeEstimate() * 16 * (calldataLength + fixedOverhead))
    function _calldataFee(
        bytes memory applicableCalldata,
        UFixed18 multiplierCalldata,
        uint256 bufferCalldata
    ) internal view virtual override returns (UFixed18) {
        return _fee(
            ARB_GAS_MULTIPLIER * (applicableCalldata.length + ARB_FIXED_OVERHEAD),
            multiplierCalldata,
            bufferCalldata,
            ARB_GAS.getL1BaseFeeEstimate()
        );
    }
}
