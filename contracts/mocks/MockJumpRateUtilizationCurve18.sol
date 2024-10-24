// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../utilization/types/JumpRateUtilizationCurve18.sol";

contract MockJumpRateUtilizationCurve18 {
    function compute(JumpRateUtilizationCurve18 memory self, UFixed18 utilization) external pure returns (Fixed18) {
        return JumpRateUtilizationCurve18Lib.compute(self, utilization);
    }

    function accumulate(
        JumpRateUtilizationCurve18 memory self,
        UFixed18 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed18 notional
    ) external pure returns (Fixed18) {
        return JumpRateUtilizationCurve18Lib.accumulate(self, utilization, fromTimestamp, toTimestamp, notional);
    }
}
