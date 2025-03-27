// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../utilization/types/JumpRateUtilizationCurve6.sol";

contract MockJumpRateUtilizationCurve6 {
    function compute(JumpRateUtilizationCurve6 memory self, UFixed6 utilization) external pure returns (UFixed6) {
        return JumpRateUtilizationCurve6Lib.compute(self, utilization);
    }

    function accumulate(
        JumpRateUtilizationCurve6 memory self,
        UFixed6 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) external pure returns (UFixed6) {
        return JumpRateUtilizationCurve6Lib.accumulate(self, utilization, fromTimestamp, toTimestamp, notional);
    }
}
