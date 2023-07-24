// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath18.sol";
import "../../number/types/UFixed18.sol";
import "../../number/types/Fixed18.sol";

/// @dev UJumpRateUtilizationCurve18 type
struct UJumpRateUtilizationCurve18 {
    UFixed18 minRate;
    UFixed18 maxRate;
    UFixed18 targetRate;
    UFixed18 targetUtilization;
}
using UJumpRateUtilizationCurve18Lib for UJumpRateUtilizationCurve18 global;

/**
 * @title UJumpRateUtilizationCurve18Lib
 * @notice Library for the unsigned Jump Rate utilization curve type
 */
library UJumpRateUtilizationCurve18Lib {
    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(UJumpRateUtilizationCurve18 memory self, UFixed18 utilization) internal pure returns (UFixed18) {
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
        UJumpRateUtilizationCurve18 memory self,
        UFixed18 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed18 notional
    ) internal pure returns (UFixed18) {
        return compute(self, utilization)
            .mul(UFixed18Lib.from(toTimestamp - fromTimestamp))
            .mul(notional)
            .div(UFixed18Lib.from(365 days));
    }
}
