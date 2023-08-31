// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "./Kept.sol";

interface OptGasInfo {
    function getL1Fee(bytes memory) external view returns (uint256);
}

contract Kept_Optimism is Kept {
    // https://community.optimism.io/docs/developers/build/transaction-fees/#the-l1-data-fee
    OptGasInfo constant OPT_GAS = OptGasInfo(0x420000000000000000000000000000000000000F);

    // https://community.optimism.io/docs/developers/build/transaction-fees/#the-l1-data-fee
    // The getL1Fee method takes into account L1 gas price, size, and overhead values
    function _calculateDynamicFee(bytes memory callData) internal view override returns (UFixed18) {
        return UFixed18.wrap(OPT_GAS.getL1Fee(callData));
    }
}
