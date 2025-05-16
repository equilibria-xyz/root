// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { UFixed6, UFixed6Lib } from "../../number/types/UFixed6.sol";
import { Fixed6, Fixed6Lib } from "../../number/types/Fixed6.sol";

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
    // sig: 0x52dbc475
    /// @custom:error Out of bounds
    error JumpRateUtilizationCurve6OutOfBoundsError();

    /// @notice Computes the corresponding rate for a utilization ratio
    /// @param utilization The utilization ratio
    /// @return The corresponding rate
    function compute(JumpRateUtilizationCurve6 memory self, UFixed6 utilization) internal pure returns (UFixed6) {
        if (utilization < self.targetUtilization) {
            return linearInterpolation(
                UFixed6Lib.ZERO,
                self.minRate,
                self.targetUtilization,
                self.targetRate,
                utilization
            );
        }
        if (utilization < UFixed6Lib.ONE) {
            return linearInterpolation(
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

    /// @notice Computes a linear interpolation between two points
    /// @param startX First point's x-coordinate
    /// @param startY First point's y-coordinate
    /// @param endX Second point's x-coordinate
    /// @param endY Second point's y-coordinate
    /// @param targetX x-coordinate to interpolate
    /// @return y-coordinate for `targetX` along the line from (`startX`, `startY`) -> (`endX`, `endY`)
    function linearInterpolation(
        UFixed6 startX,
        Fixed6 startY,
        UFixed6 endX,
        Fixed6 endY,
        UFixed6 targetX
    ) internal pure returns (Fixed6) {
        if (targetX < startX || targetX > endX) revert JumpRateUtilizationCurve6OutOfBoundsError();

        UFixed6 xRange = endX - startX;
        Fixed6 yRange = endY - startY;
        UFixed6 xRatio = (targetX - startX) / xRange;
        return yRange * Fixed6Lib.from(xRatio) + startY;
    }

    /// @notice Computes a linear interpolation between two points
    /// @param startX First point's x-coordinate
    /// @param startY First point's y-coordinate
    /// @param endX Second point's x-coordinate
    /// @param endY Second point's y-coordinate
    /// @param targetX x-coordinate to interpolate
    /// @return y-coordinate for `targetX` along the line from (`startX`, `startY`) -> (`endX`, `endY`)
    function linearInterpolation(
        UFixed6 startX,
        UFixed6 startY,
        UFixed6 endX,
        UFixed6 endY,
        UFixed6 targetX
    ) internal pure returns (UFixed6) {
        return UFixed6Lib.from(linearInterpolation(startX, Fixed6Lib.from(startY), endX, Fixed6Lib.from(endY), targetX));
    }
}
