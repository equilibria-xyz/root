// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { UFixed18, UFixed18Lib } from "../../number/types/UFixed18.sol";
import { Fixed18, Fixed18Lib } from "../../number/types/Fixed18.sol";

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
    // sig: 0xdaad1c31
    /// @custom:error Out of bounds
    error JumpRateUtilizationCurve18OutOfBoundsError();

    /// @notice Computes the corresponding rate for a utilization ratio
    /// @param utilization The utilization ratio
    /// @return The corresponding rate
    function compute(JumpRateUtilizationCurve18 memory self, UFixed18 utilization) internal pure returns (UFixed18) {
        if (utilization < self.targetUtilization) {
            return linearInterpolation(
                UFixed18Lib.ZERO,
                self.minRate,
                self.targetUtilization,
                self.targetRate,
                utilization
            );
        }
        if (utilization< UFixed18Lib.ONE) {
            return linearInterpolation(
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

    /// @notice Computes a linear interpolation between two points
    /// @param startX First point's x-coordinate
    /// @param startY First point's y-coordinate
    /// @param endX Second point's x-coordinate
    /// @param endY Second point's y-coordinate
    /// @param targetX x-coordinate to interpolate
    /// @return y-coordinate for `targetX` along the line from (`startX`, `startY`) -> (`endX`, `endY`)
    function linearInterpolation(
        UFixed18 startX,
        Fixed18 startY,
        UFixed18 endX,
        Fixed18 endY,
        UFixed18 targetX
    ) internal pure returns (Fixed18) {
        if (targetX < startX || targetX > endX) revert JumpRateUtilizationCurve18OutOfBoundsError();

        UFixed18 xRange = endX - startX;
        Fixed18 yRange = endY - startY;
        UFixed18 xRatio = (targetX - startX) / xRange;
        return yRange * Fixed18Lib.from(xRatio) + startY;
    }

    /// @notice Computes a linear interpolation between two points
    /// @param startX First point's x-coordinate
    /// @param startY First point's y-coordinate
    /// @param endX Second point's x-coordinate
    /// @param endY Second point's y-coordinate
    /// @param targetX x-coordinate to interpolate
    /// @return y-coordinate for `targetX` along the line from (`startX`, `startY`) -> (`endX`, `endY`)
    function linearInterpolation(
        UFixed18 startX,
        UFixed18 startY,
        UFixed18 endX,
        UFixed18 endY,
        UFixed18 targetX
    ) internal pure returns (UFixed18) {
        return UFixed18Lib.from(linearInterpolation(startX, Fixed18Lib.from(startY), endX, Fixed18Lib.from(endY), targetX));
    }
}
