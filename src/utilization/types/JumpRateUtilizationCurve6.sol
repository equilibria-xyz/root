// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath6.sol";
import "../../number/types/UFixed6.sol";

/// @dev JumpRateUtilizationCurve6 type
struct JumpRateUtilizationCurve6 {
    UFixed6 minRate;
    UFixed6 maxRate;
    UFixed6 targetRate;
    UFixed6 targetUtilization;
}
using JumpRateUtilizationCurve6Lib for JumpRateUtilizationCurve6 global;

/// @title JumpRateUtilizationCurve6Lib
/// @notice Library for the unsigned base-6 Jump Rate utilization curve type
library JumpRateUtilizationCurve6Lib {
    /// @notice Computes the corresponding rate for a utilization ratio
    /// @param utilization The utilization ratio
    /// @return The corresponding rate
    function compute(JumpRateUtilizationCurve6 memory self, UFixed6 utilization) internal pure returns (UFixed6) {
        if (utilization < self.targetUtilization) {
            return CurveMath6.linearInterpolation(
                UFixed6Lib.ZERO,
                self.minRate,
                self.targetUtilization,
                self.targetRate,
                utilization
            );
        }
        if (utilization < UFixed6Lib.ONE) {
            return CurveMath6.linearInterpolation(
                self.targetUtilization,
                self.targetRate,
                UFixed6Lib.ONE,
                self.maxRate,
                utilization
            );
        }
        return self.maxRate;
    }

    function accumulate(
        JumpRateUtilizationCurve6 memory self,
        UFixed6 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) internal pure returns (UFixed6) {
        return compute(self, utilization)
            * UFixed6Lib.from(toTimestamp - fromTimestamp)
            * notional
            / UFixed6Lib.from(365 days);
    }
}
