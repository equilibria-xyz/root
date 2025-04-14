// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { RootTest } from "../RootTest.sol";

import { CurveMath6 } from "src/utilization/CurveMath6.sol";
import { Fixed6, Fixed6Lib } from "src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "src/number/types/UFixed6.sol";

contract CurveMath6Test is RootTest {
    MockCurveMath6 m = new MockCurveMath6();

    // increasing

    function test_increasingRevertsBeforeStart() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 200, 100, 0);
    }

    function test_increasing() public view {
        Fixed6 result = m.linearInterpolationWholeNumbers(0, 0, 100, 100, 0);
        assertFixed6Eq(result, Fixed6Lib.ZERO, "returns correct y-coordinate at start");
        result = m.linearInterpolationWholeNumbers(0, 0, 100, 100, 50);
        assertFixed6Eq(result, Fixed6Lib.from(50), "returns correct y-coordinate at middle");
        result = m.linearInterpolationWholeNumbers(0, 0, 100, 100, 100);
        assertFixed6Eq(result, Fixed6Lib.from(100), "returns correct y-coordinate at end");
    }

    function test_increasingRevertsAfterEnd() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 200, 100, 300);
    }

    // decreasing

    function test_decreasingRevertsBeforeStart() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 0, 0);
    }

    function test_decreasing() public view {
        Fixed6 result = m.linearInterpolationWholeNumbers(0, 100, 100, 0, 0);
        assertFixed6Eq(result, Fixed6Lib.from(100), "returns correct y-coordinate at start");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 0, 50);
        assertFixed6Eq(result, Fixed6Lib.from(50), "returns correct y-coordinate at middle");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 0, 100);
        assertFixed6Eq(result, Fixed6Lib.ZERO, "returns correct y-coordinate at end");
    }

    function test_decreasingRevertsAfterEnd() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 0, 300);
    }

    // horizontal

    function test_horizontalRevertsBeforeStart() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 100, 0);
    }

    function test_horizontal() public view {
        Fixed6 result = m.linearInterpolationWholeNumbers(0, 100, 100, 100, 0);
        assertFixed6Eq(result, Fixed6Lib.from(100), "returns correct y-coordinate at start");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 100, 50);
        assertFixed6Eq(result, Fixed6Lib.from(100), "returns correct y-coordinate at middle");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 100, 100);
        assertFixed6Eq(result, Fixed6Lib.from(100), "returns correct y-coordinate at end");
    }

    function test_horizontalRevertsAfterEnd() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 100, 300);
    }

    // vertical

    function test_verticalRevertsBeforeStart() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 200, 100, 0);
    }

    function test_verticaRevertsWithDivideByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.linearInterpolationWholeNumbers(100, 0, 100, 100, 100);
    }

    function test_verticalRevertsAfterEnd() public {
        vm.expectRevert(CurveMath6.CurveMath6OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 100, 100, 300);
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

    /// @dev for test readability
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
