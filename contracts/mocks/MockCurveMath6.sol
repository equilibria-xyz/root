// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/CurveMath6.sol";

contract MockCurveMath6 {
    function linearInterpolation(
        UFixed6 startX,
        Fixed6 startY,
        UFixed6 endX,
        Fixed6 endY,
        UFixed6 targetX
    ) external pure returns (Fixed6) {
        return CurveMath6.linearInterpolation(startX, startY, endX, endY, targetX);
    }
}
