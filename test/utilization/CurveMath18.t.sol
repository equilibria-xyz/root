// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { RootTest } from "../RootTest.sol";

import { CurveMath18 } from "src/utilization/CurveMath18.sol";
import { Fixed18, Fixed18Lib } from "src/number/types/Fixed18.sol";
import { UFixed18, UFixed18Lib } from "src/number/types/UFixed18.sol";

contract CurveMath18Test is RootTest {
    MockCurveMath18 m = new MockCurveMath18();

    // increasing

    function test_increasingRevertsBeforeStart() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 200, 100, 0);
    }

    function test_increasing() public view {
        Fixed18 result = m.linearInterpolationWholeNumbers(0, 0, 100, 100, 0);
        assertFixed18Eq(result, Fixed18Lib.ZERO, "returns correct y-coordinate at start");
        result = m.linearInterpolationWholeNumbers(0, 0, 100, 100, 50);
        assertFixed18Eq(result, Fixed18Lib.from(50), "returns correct y-coordinate at middle");
        result = m.linearInterpolationWholeNumbers(0, 0, 100, 100, 100);
        assertFixed18Eq(result, Fixed18Lib.from(100), "returns correct y-coordinate at end");
    }

    function test_inecreasingRevertsAfterEnd() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 200, 100, 300);
    }

    // decreasing
    function test_decreasingRevertsBeforeStart() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 0, 0);
    }

    function test_decreasing() public view {
        Fixed18 result = m.linearInterpolationWholeNumbers(0, 100, 100, 0, 0);
        assertFixed18Eq(result, Fixed18Lib.from(100), "returns correct y-coordinate at start");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 0, 50);
        assertFixed18Eq(result, Fixed18Lib.from(50), "returns correct y-coordinate at middle");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 0, 100);
        assertFixed18Eq(result, Fixed18Lib.ZERO, "returns correct y-coordinate at end");
    }

    function test_decreasingRevertsAfterEnd() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 0, 300);
    }

    // horizontal

    function test_horizontalRevertsBeforeStart() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 100, 0);
    }

    function test_horizontal() public view {
        Fixed18 result = m.linearInterpolationWholeNumbers(0, 100, 100, 100, 0);
        assertFixed18Eq(result, Fixed18Lib.from(100), "returns correct y-coordinate at start");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 100, 50);
        assertFixed18Eq(result, Fixed18Lib.from(100), "returns correct y-coordinate at middle");
        result = m.linearInterpolationWholeNumbers(0, 100, 100, 100, 100);
        assertFixed18Eq(result, Fixed18Lib.from(100), "returns correct y-coordinate at end");
    }

    function test_horizontalRevertsAfterEnd() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 100, 200, 100, 300);
    }

    // vertical

    function test_verticalRevertsBeforeStart() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 200, 100, 0);
    }

    function test_verticalRevertsWithDivideByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.linearInterpolationWholeNumbers(100, 0, 100, 100, 100);
    }

    function test_verticalRevertsAfterEnd() public {
        vm.expectRevert(CurveMath18.CurveMath18OutOfBoundsError.selector);
        m.linearInterpolationWholeNumbers(100, 0, 100, 100, 300);
    }
}

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

    /// @dev for test readability
    function linearInterpolationWholeNumbers(
        uint256 startX,
        int256 startY,
        uint256 endX,
        int256 endY,
        uint256 targetX
    ) external pure returns (Fixed18) {
        return CurveMath18.linearInterpolation(
            UFixed18Lib.from(startX),
            Fixed18Lib.from(startY),
            UFixed18Lib.from(endX),
            Fixed18Lib.from(endY),
            UFixed18Lib.from(targetX)
        );
    }
}
