// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { CurveMath18 } from "../CurveMath18.sol";
import { UFixed18, UFixed18Lib } from "../../number/types/UFixed18.sol";

/// @dev JumpRateUtilizationCurve18 type
struct JumpRateUtilizationCurve18 {
    UFixed18 minRate;
    UFixed18 maxRate;
    UFixed18 targetRate;
    UFixed18 targetUtilization;
}
using JumpRateUtilizationCurve18Lib for JumpRateUtilizationCurve18 global;

/// @title JumpRateUtilizationCurve18Lib
/// @notice Library for the unsigned Jump Rate utilization curve type
library JumpRateUtilizationCurve18Lib {
    /// @notice Computes the corresponding rate for a utilization ratio
    /// @param utilization The utilization ratio
    /// @return The corresponding rate
    function compute(JumpRateUtilizationCurve18 memory self, UFixed18 utilization) internal pure returns (UFixed18) {
        if (utilization < self.targetUtilization) {
            return CurveMath18.linearInterpolation(
                UFixed18Lib.ZERO,
                self.minRate,
                self.targetUtilization,
                self.targetRate,
                utilization
            );
        }
        if (utilization< UFixed18Lib.ONE) {
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
    ) internal pure returns (UFixed18) {
        return compute(self, utilization)
            * UFixed18Lib.from(toTimestamp - fromTimestamp)
            * notional
            / UFixed18Lib.from(365 days);
    }
}
