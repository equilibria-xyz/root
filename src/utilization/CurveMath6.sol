// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { UFixed6, UFixed6Lib } from "src/number/types/UFixed6.sol";
import { Fixed6, Fixed6Lib } from "src/number/types/Fixed6.sol";

/// @title CurveMath6
/// @notice Library for managing math operations for utilization curves.
library CurveMath6 {
    // sig: 0x4a83a53f
    /// @custom:error Out of bounds
    error CurveMath6OutOfBoundsError();

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
        if (targetX < startX || targetX > endX) revert CurveMath6OutOfBoundsError();

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
