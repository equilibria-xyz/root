// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath18.sol";
import "../../number/types/UFixed18.sol";
import "../../number/types/Fixed18.sol";

/// @dev JumpRateUtilizationCurve18 type
struct JumpRateUtilizationCurve18 {
    Fixed18 minRate;
    Fixed18 maxRate;
    Fixed18 targetRate;
    UFixed18 targetUtilization;
}
using JumpRateUtilizationCurve18Lib for JumpRateUtilizationCurve18 global;

/**
 * @title JumpRateUtilizationCurve18Lib
 * @notice Library for the Jump Rate utilization curve type
 */
library JumpRateUtilizationCurve18Lib {
    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(JumpRateUtilizationCurve18 memory self, UFixed18 utilization) internal pure returns (Fixed18) {
        if (utilization.lt(self.targetUtilization)) {
            return CurveMath18.linearInterpolation(
                UFixed18Lib.ZERO,
                self.minRate,
                self.targetUtilization,
                self.targetRate,
                utilization
            );
        }
        if (utilization.lt(UFixed18Lib.ONE)) {
            return CurveMath18.linearInterpolation(
                self.targetUtilization,
                self.targetRate,
                UFixed18Lib.ONE,
                self.maxRate,
                utilization
            );
        }
        return self.maxRate;
    }

    function accumulate(
        JumpRateUtilizationCurve18 memory self,
        UFixed18 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed18 notional
    ) internal pure returns (Fixed18) {
        return compute(self, utilization)
            .mul(Fixed18Lib.from(int256(toTimestamp - fromTimestamp)))
            .mul(Fixed18Lib.from(notional))
            .div(Fixed18Lib.from(365 days));
    }
}
