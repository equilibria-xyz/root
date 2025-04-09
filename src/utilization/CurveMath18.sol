// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../number/types/UFixed18.sol";
import "../number/types/Fixed18.sol";

/**
 * @title CurveMath18
 * @notice Library for managing math operations for utilization curves.
 */
library CurveMath18 {
    // sig: 0xcbaada7d
    /// @custom:error Out of bounds
    error CurveMath18OutOfBoundsError();

    /**
     * @notice Computes a linear interpolation between two points
     * @param startX First point's x-coordinate
     * @param startY First point's y-coordinate
     * @param endX Second point's x-coordinate
     * @param endY Second point's y-coordinate
     * @param targetX x-coordinate to interpolate
     * @return y-coordinate for `targetX` along the line from (`startX`, `startY`) -> (`endX`, `endY`)
     */
    function linearInterpolation(
        UFixed18 startX,
        Fixed18 startY,
        UFixed18 endX,
        Fixed18 endY,
        UFixed18 targetX
    ) internal pure returns (Fixed18) {
        if (targetX < startX || targetX > endX) revert CurveMath18OutOfBoundsError();

        UFixed18 xRange = endX - startX;
        Fixed18 yRange = endY - startY;
        UFixed18 xRatio = (targetX - startX) / xRange;
        return yRange * Fixed18Lib.from(xRatio) + startY;
    }

    /**
     * @notice Computes a linear interpolation between two points
     * @param startX First point's x-coordinate
     * @param startY First point's y-coordinate
     * @param endX Second point's x-coordinate
     * @param endY Second point's y-coordinate
     * @param targetX x-coordinate to interpolate
     * @return y-coordinate for `targetX` along the line from (`startX`, `startY`) -> (`endX`, `endY`)
     */
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
