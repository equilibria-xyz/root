// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { Test } from "forge-std/Test.sol";

import { NumberMath } from "src/number/NumberMath.sol";

contract NumberMathTest is Test {
    MockNumberMath m = new MockNumberMath();

    function test_divOutUnsigned() public pure {
        assertEq(NumberMath.divOut(uint(20), 10), 2, "divides without rounding");
        assertEq(NumberMath.divOut(uint(21), 10), 3, "divides ands rounds away from 0");
        assertEq(NumberMath.divOut(uint(0), 10), 0, "divides 0");
    }

    function test_revertsIfDivideByZeroUnsignedUnderflow() public {
        // We get an overflow/underflow error because we subtract 1 from 0.
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(uint(0), 0);
    }

    function test_revertsIfDivideByZeroUnsigned() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(uint(20), 0);
    }

    function test_divOutSignedWithoutRounding() public pure {
        assertEq(NumberMath.divOut(int(20), 10), int(2), "divides without rounding");
        assertEq(NumberMath.divOut(int(20), -10), -2, "divides by negative number without rounding");
        assertEq(NumberMath.divOut(-20, 10), -2, "divides negative number without rounding");
        assertEq(NumberMath.divOut(-20, -10), 2, "divides two negative numbers without rounding");
    }

    function test_divOutSignedRoundsAwayFromZero() public pure {
        assertEq(NumberMath.divOut(int(21), 10), int(3), "divides and rounds away from 0");
        assertEq(NumberMath.divOut(int(21), -10), -3, "divides by negative number and rounds away from 0");
        assertEq(NumberMath.divOut(-21, 10), -3, "divides negative number and rounds away from 0");
        assertEq(NumberMath.divOut(-21, -10), 3, "divides two negative numbers and rounds away from 0");
    }

    function test_revertsIfDivideByZeroSignedUnderflow() public {
        // We get an overflow/underflow error because we subtract 1 from 0.
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(int(0), 0);
    }

    function test_revertsIfDivideByZeroSigned() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(int(20), 0);
    }

    function test_revertsIfDivideNegativeByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(int(-20), 0);
    }

    function test_signIsPositive() public pure {
        assertEq(NumberMath.sign(12), 1, "sign of positive number is 1");
        assertEq(NumberMath.sign(0), 0, "sign of 0 is 0");
        assertEq(NumberMath.sign(-12), -1, "sign of negative number is -1");
    }
}

contract MockNumberMath {
    function divOut(uint256 a, uint256 b) external pure returns (uint256) {
        return NumberMath.divOut(a, b);
    }

    function divOut(int256 a, int256 b) external pure returns (int256) {
        return NumberMath.divOut(a, b);
    }
}
