// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/CurveMath18.sol";

contract MockCurveMath18 {
    function linearInterpolation(
        UFixed18 startX,
        Fixed18 startY,
        UFixed18 endX,
        Fixed18 endY,
        UFixed18 targetX
    ) external pure returns (Fixed18) {
        return CurveMath18.linearInterpolation(startX, startY, endX, endY, targetX);
    }
}
