// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { RootTest } from "../RootTest.sol";

import { CurveMath6 } from "../../src/utilization/CurveMath6.sol";
import { Fixed6, Fixed6Lib } from "../../src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";

contract CurveMath6Test is RootTest {
    MockCurveMath6 m = new MockCurveMath6();

    function test_revertsBeforeStart() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 200, 100, 0);
    }
}

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

    function linearInterpolationWholeNumbers(
        uint256 startX,
        int256 startY,
        uint256 endX,
        int256 endY,
        uint256 targetX
    ) external pure returns (Fixed6) {
        return CurveMath6.linearInterpolation(
            UFixed6Lib.from(startX),
            Fixed6Lib.from(startY),
            UFixed6Lib.from(endX),
            Fixed6Lib.from(endY),
            UFixed6Lib.from(targetX)
        );
    }
}
