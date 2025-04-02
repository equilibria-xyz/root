// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { Test } from "forge-std/Test.sol";

import { Fixed6, Fixed6Lib, Fixed6Storage, Fixed6StorageLib } from "../../src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";
import { Fixed18, Fixed18Lib } from "../../src/number/types/Fixed18.sol";
import { NumberMath } from "../../src/number/NumberMath.sol";

contract Fixed6Test is Test {
    MockFixed6 m = new MockFixed6();
    uint256 constant TOO_LARGE_UNSIGNED = 2 ** 256 - 10;
    int256 constant TOO_LARGE_SIGNED = type(int256).max - 10;

    function test_constants() public pure {
        assertEq(Fixed6.unwrap(Fixed6Lib.ZERO), 0);
        assertEq(Fixed6.unwrap(Fixed6Lib.ONE), 1e6);
        assertEq(Fixed6.unwrap(Fixed6Lib.NEG_ONE), -1e6);
        assertEq(Fixed6.unwrap(Fixed6Lib.MAX), type(int256).max);
        assertEq(Fixed6.unwrap(Fixed6Lib.MIN), type(int256).min);
    }

    function test_fromSigned() public pure {
        Fixed6 f6 = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(f6), 10e6);
    }

    function test_fromSignedRevertsIfTooLarge() public {
        // cannot test panics directly from library
        vm.expectRevert(stdError.arithmeticError);
        m.from(TOO_LARGE_SIGNED);
    }

    function test_fromUnsignedWithSign() public pure {
        int256 ten = 10e6;
        UFixed6 ten_u6 = UFixed6Lib.from(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.from(int(1), ten_u6)), int(ten), "Creates positive");
        assertEq(Fixed6.unwrap(Fixed6Lib.from(int(0), ten_u6)), 0, "Creates zero");
        assertEq(Fixed6.unwrap(Fixed6Lib.from(-1, ten_u6)), int(-ten), "Creates negative");
    }

    function test_fromUnsignedWithSignRevertsIfTooLarge() public {
        UFixed6 too_large = UFixed6.wrap(TOO_LARGE_UNSIGNED);
        // cannot test reverts directly from library
        vm.expectRevert(abi.encodeWithSelector(Fixed6Lib.Fixed6OverflowError.selector, TOO_LARGE_UNSIGNED));
        m.from(1, too_large);
    }

    function test_fromUnsignedWithSignRevertsIfTooSmall() public {
        UFixed6 too_large = UFixed6.wrap(TOO_LARGE_UNSIGNED);
        vm.expectRevert(abi.encodeWithSelector(Fixed6Lib.Fixed6OverflowError.selector, TOO_LARGE_UNSIGNED));
        m.from(-1, too_large);
    }

    function test_fromUnsignedWithoutSign() public pure {
        UFixed6 ten_u6 = UFixed6Lib.from(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.from(ten_u6)), int(10e6), "Creates from UFixed6");
    }

    function test_fromUnsignedWithoutSignRevertsIfTooLarge() public {
        UFixed6 too_large = UFixed6.wrap(TOO_LARGE_UNSIGNED);
        vm.expectRevert(abi.encodeWithSelector(Fixed6Lib.Fixed6OverflowError.selector, TOO_LARGE_UNSIGNED));
        m.from(too_large);
    }

    function test_fromFixed18() public view {
        Fixed18 ten_f18 = Fixed18Lib.from(10);
        assertEq(Fixed6.unwrap(m.fromFixed18(ten_f18)), int(10e6));
    }

    function test_fromFixed18RoundsTowardZero() public view {
        Fixed18 a = Fixed18.wrap(1e11);
        assertEq(Fixed6.unwrap(m.fromFixed18(a)), 0);
    }

    function test_fromFixed18RoundsAwayFromZero() public pure {
        Fixed18 a = Fixed18.wrap(1);
        assertEq(Fixed6.unwrap(Fixed6Lib.from(a, true)), 1);

        Fixed18 b = Fixed18.wrap(-1);
        assertEq(Fixed6.unwrap(Fixed6Lib.from(b, true)), -1);
    }

    function test_fromSignificantAndExponent() public pure {
        Fixed6 ten_pow_2 = Fixed6Lib.from(Fixed6Lib.from(10), 2);
        assertEq(Fixed6.unwrap(ten_pow_2), 10e8, "10^2");
        Fixed6 neg_ten_pow_2 = Fixed6Lib.from(Fixed6Lib.from(-10), 2);
        assertEq(Fixed6.unwrap(neg_ten_pow_2), -10e8, "-10^2");

        Fixed6 ten_pow_neg2 = Fixed6Lib.from(Fixed6Lib.from(10), -2);
        assertEq(Fixed6.unwrap(ten_pow_neg2), 10e4, "10^-2");
        Fixed6 neg_ten_pow_neg2 = Fixed6Lib.from(Fixed6Lib.from(-10), -2);
        assertEq(Fixed6.unwrap(neg_ten_pow_neg2), -10e4, "-10^-2");

        assertEq(Fixed6.unwrap(Fixed6Lib.from(Fixed6Lib.ZERO, 6)), 0, "0^6");
        assertEq(Fixed6.unwrap(Fixed6Lib.from(Fixed6Lib.ZERO, 0)), 0, "0^0");

        Fixed6 ten_pow_0 = Fixed6Lib.from(Fixed6Lib.from(10), 0);
        assertEq(Fixed6.unwrap(ten_pow_0), 10e6, "10^0");
        Fixed6 neg_ten_pow_0 = Fixed6Lib.from(Fixed6Lib.from(-10), 0);
        assertEq(Fixed6.unwrap(neg_ten_pow_0), -10e6, "-10^0");

        Fixed6 LARGE_SIGNIFICAND = Fixed6.wrap(1e40);
        assertEq(Fixed6.unwrap(Fixed6Lib.from(LARGE_SIGNIFICAND, 1)), 1e41);
        assertEq(Fixed6.unwrap(Fixed6Lib.from(LARGE_SIGNIFICAND, -1)), 1e39);
    }

    function test_fromSignificantAndExponentRevertsIfTooLarge() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(Fixed6Lib.ONE, type(int256).max);
    }

    function test_fromSignificantAndExponentRevertsIfTooSmall() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(Fixed6Lib.ONE, type(int256).min + 1);
    }

    function test_isZero() public pure {
        assertEq(Fixed6Lib.isZero(Fixed6Lib.ZERO), true, "0 is zero");
        assertEq(Fixed6Lib.isZero(Fixed6Lib.ONE), false, "1 is not zero");
        assertEq(Fixed6Lib.isZero(Fixed6Lib.NEG_ONE), false, "-1 is not zero");
    }

    function test_addition() public pure {
        Fixed6 a = Fixed6Lib.from(10);
        Fixed6 b = Fixed6Lib.from(20);
        assertEq(Fixed6.unwrap(a.add(b)), 30e6, "10 + 20 = 30");

        a = Fixed6Lib.from(-10);
        b = Fixed6Lib.from(-20);
        assertEq(Fixed6.unwrap(a + b), -30e6, "-10 + -20 = -30");
    }

    function test_subtraction() public pure {
        Fixed6 a = Fixed6Lib.from(20);
        Fixed6 b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(a.sub(b)), 10e6, "20 - 10 = 10");

        a = Fixed6Lib.from(-20);
        b = Fixed6Lib.from(-10);
        assertEq(Fixed6.unwrap(a - b), -10e6, "-20 - -10 = -10");
    }

    function test_multiplication() public pure {
        Fixed6 a = Fixed6Lib.from(20);
        Fixed6 b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.mul(a, b)), 200e6, "20 * 10 = 200");
        a = Fixed6Lib.from(-20);
        assertEq(Fixed6.unwrap(Fixed6Lib.mul(a, b)), -200e6, "-20 * 10 = -200");
        b = Fixed6Lib.from(-10);
        assertEq(Fixed6.unwrap(a * b), 200e6, "-20 * -10 = 200");
        a = Fixed6Lib.from(20);
        assertEq(Fixed6.unwrap(a * b), -200e6, "20 * -10 = -200");
    }

    function test_MultiplicationRoundsTowardZero() public pure {
        Fixed6 a = Fixed6.wrap(1);
        Fixed6 b = Fixed6.wrap(2);
        assertEq(Fixed6.unwrap(Fixed6Lib.mul(a, b)), 0, "0.0000001 * 0.0000002 = 0");
        a = Fixed6.wrap(-1);
        assertEq(Fixed6.unwrap(Fixed6Lib.mul(a, b)), 0, "-0.0000001 * 0.0000002 = 0");
        b = Fixed6.wrap(-2);
        assertEq(Fixed6.unwrap(Fixed6Lib.mul(a, b)), 0, "-0.0000001 * -0.0000002 = 0");
        a = Fixed6.wrap(1);
        assertEq(Fixed6.unwrap(Fixed6Lib.mul(a, b)), 0, "0.0000001 * -0.0000002 = 0");
    }

    function test_multiplicationOut() public pure {
        Fixed6 a = Fixed6Lib.from(20);
        Fixed6 b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), 200e6, "20 * 10 = 200");
        a = Fixed6Lib.from(-20);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), -200e6, "-20 * 10 = -200");
        b = Fixed6Lib.from(-10);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), 200e6, "-20 * -10 = 200");
        a = Fixed6Lib.from(20);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), -200e6, "20 * -10 = -200");
    }

    function test_multiplicationOutRoundsAwayFromZero() public pure {
        Fixed6 a = Fixed6.wrap(1);
        Fixed6 b = Fixed6.wrap(2);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), 1, "0.0000001 * 0.0000002 = 0.0000001");
        a = Fixed6.wrap(-1);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), -1, "-0.0000001 * 0.0000002 = -0.0000001");
        b = Fixed6.wrap(-2);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), 1, "-0.0000001 * -0.0000002 = 0.0000001");
        a = Fixed6.wrap(1);
        assertEq(Fixed6.unwrap(Fixed6Lib.mulOut(a, b)), -1, "0.0000001 * -0.0000002 = -0.0000001");
    }

    function test_division() public pure {
        Fixed6 a = Fixed6.wrap(20);
        Fixed6 b = Fixed6.wrap(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.div(a, b)), 2e6, "20 / 10 = 2");
        a = Fixed6.wrap(-20);
        assertEq(Fixed6.unwrap(Fixed6Lib.div(a, b)), -2e6, "-20 / 10 = -2");
        b = Fixed6.wrap(-10);
        assertEq(Fixed6.unwrap(a / b), 2e6, "-20 / -10 = 2");
        a = Fixed6.wrap(20);
        assertEq(Fixed6.unwrap(a / b), -2e6, "20 / -10 = -2");
    }

    function test_divisionRoundsTowardsZero() public pure {
        Fixed6 a = Fixed6.wrap(21);
        Fixed6 b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.div(a, b)), 2, "0.000021 / 0.000010 = 2");
        a = Fixed6.wrap(-21);
        assertEq(Fixed6.unwrap(Fixed6Lib.div(a, b)), -2, "-0.000021 / 0.000010 = -2");
    }

    function test_divisionZeroByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(Fixed6Lib.ZERO, Fixed6Lib.ZERO);
    }

    function test_divisionPositiveByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(Fixed6Lib.from(20), Fixed6Lib.ZERO);
    }

    function test_divisionNegativeByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(Fixed6Lib.from(-20), Fixed6Lib.ZERO);
    }

    function test_divisionOutWithoutRounding() public view {
        Fixed6 a = Fixed6.wrap(20);
        Fixed6 b = Fixed6.wrap(10);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), 2e6, "20 / 10 = 2");
        a = Fixed6.wrap(-20);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), -2e6, "-20 / 10 = -2");
        b = Fixed6.wrap(-10);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), 2e6, "-20 / -10 = 2");
        a = Fixed6.wrap(20);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), -2e6, "20 / -10 = -2");
    }

    function test_divisionRoundsAwayFromZero() public view {
        Fixed6 a = Fixed6.wrap(21);
        Fixed6 b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), 3, "0.000021 / 10 = 0.000003");
        a = Fixed6.wrap(-21);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), -3, "-0.000021 / 10 = -0.000003");
        b = Fixed6Lib.from(-10);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), 3, "-0.000021 / -10 = 0.000003");
        a = Fixed6.wrap(21);
        assertEq(Fixed6.unwrap(m.divOut(a, b)), -3, "0.000021 / -10 = -0.000003");
    }

    function test_divisionOutZeroByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(Fixed6Lib.ZERO, Fixed6Lib.ZERO);
    }

    function test_divisionOutPositiveByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(Fixed6Lib.from(20), Fixed6Lib.ZERO);
    }

    function test_divisionOutNegativeByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(Fixed6Lib.from(-20), Fixed6Lib.ZERO);
    }

    function test_unsafeDivision() public view {
        Fixed6 a = Fixed6Lib.from(20);
        Fixed6 b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(m.unsafeDiv(a, b)), 2e6, "20 / 10 = 2");
        a = Fixed6Lib.from(-20);
        b = Fixed6Lib.from(-10);
        assertEq(Fixed6.unwrap(m.unsafeDiv(a, b)), 2e6, "-20 / -10 = 2");

        a = Fixed6.wrap(21);
        b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(m.unsafeDiv(a, b)), 2, "divides and floors");

        assertEq(Fixed6.unwrap(m.unsafeDiv(Fixed6Lib.ZERO, Fixed6Lib.ZERO)), 1e6, "0 / 0 = 1");
        a = Fixed6Lib.from(20);
        assertEq(Fixed6.unwrap(m.unsafeDiv(a, Fixed6Lib.ZERO)), type(int256).max, "20 / 0 = MaxInt");
        a = Fixed6Lib.from(-20);
        assertEq(Fixed6.unwrap(m.unsafeDiv(a, Fixed6Lib.ZERO)), type(int256).min, "-20 / 0 = MinInt");
    }

    function test_unsafeDivisionOut() public view {
        Fixed6 a = Fixed6Lib.from(20);
        Fixed6 b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(m.unsafeDivOut(a, b)), 2e6, "20 / 10 = 2");
        a = Fixed6Lib.from(-20);
        b = Fixed6Lib.from(-10);
        assertEq(Fixed6.unwrap(m.unsafeDivOut(a, b)), 2e6, "-20 / -10 = 2");

        a = Fixed6.wrap(21);
        b = Fixed6Lib.from(10);
        assertEq(Fixed6.unwrap(m.unsafeDivOut(a, b)), 3, "divides and ceils");

        assertEq(Fixed6.unwrap(m.unsafeDivOut(Fixed6Lib.ZERO, Fixed6Lib.ZERO)), 1e6, "0 / 0 = 1");
        a = Fixed6Lib.from(20);
        assertEq(Fixed6.unwrap(m.unsafeDivOut(a, Fixed6Lib.ZERO)), type(int256).max, "20 / 0 = MaxInt");
        a = Fixed6Lib.from(-20);
        assertEq(Fixed6.unwrap(m.unsafeDivOut(a, Fixed6Lib.ZERO)), type(int256).min, "-20 / 0 = MinInt");
    }

    function test_mulDiv() public pure {
        Fixed6 a = Fixed6Lib.from(20);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, int(10e6), int(2e6))), 100e6, "muldiv(Fixed6, int256, int256) positive");

        Fixed6 b = Fixed6Lib.from(10);
        Fixed6 c = Fixed6Lib.from(2);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, b, c)), 100e6, "muldiv(f6, i, i) positive");

        a = Fixed6Lib.from(-20);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, 10e6, 2e6)), -100e6, "muldiv(f6, i, i) negative");

        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, b, c)), -100e6, "muldiv(f6, f6, f6) negative");

        a = Fixed6.wrap(1_111111);
        b = Fixed6.wrap(3_333333);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, b, b)), 1_111111, "muldiv(f6, f6, f6) precision");
    }

    function test_mulDivRoundsTowardsZero() public pure {
        Fixed6 a = Fixed6.wrap(1);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, 21, 10)), 2, "muldiv(f6, i, i) 1*21/10 = 2");
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, 21, -10)), -2, "muldiv(f6, i, i) 1*21/-10 = -2");
        a = Fixed6.wrap(-1);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, 21, 10)), -2, "muldiv(f6, i, i) -1*21/10 = -2");
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, 21, -10)), 2, "muldiv(f6, i, i) -1*21/-10 = 2");

        a = Fixed6.wrap(1);
        Fixed6 b = Fixed6.wrap(21);
        Fixed6 c = Fixed6.wrap(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, b, c)), 2, "muldiv(f6, f6, f6) 1*21/10 = 2");
        c = Fixed6.wrap(-10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, b, c)), -2, "muldiv(f6, f6, f6) 1*21/-10 = -2");
        a = Fixed6.wrap(-1);
        c = Fixed6.wrap(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, b, c)), -2, "muldiv(f6, f6, f6) -1*21/10 = -2");
        c = Fixed6.wrap(-10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldiv(a, b, c)), 2, "muldiv(f6, f6, f6) -1*21/-10 = 2");
    }

    function test_mulDivSignedRevertsIfDivisorIsZero() public {
        Fixed6 a = Fixed6Lib.from(20);
        vm.expectRevert(stdError.divisionError);
        m.muldivSigned(a, 10e6, 0);
    }

    function test_mulDivFixedRevertsIfDivisorIsZero() public {
        Fixed6 a = Fixed6Lib.from(20);
        Fixed6 b = Fixed6Lib.from(10);
        Fixed6 c = Fixed6Lib.ZERO;
        vm.expectRevert(stdError.divisionError);
        m.muldivFixed(a, b, c);
    }

    function test_mulDivOut() public pure {
        Fixed6 a = Fixed6Lib.from(20);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, 10e6, 2e6)), 100e6, "muldivOut(f6, i, i) positive");

        Fixed6 b = Fixed6Lib.from(10);
        Fixed6 c = Fixed6Lib.from(2);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, b, c)), 100e6, "muldivOut(f6, f6, f6) positive");

        a = Fixed6Lib.from(-20);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, 10e6, 2e6)), -100e6, "muldivOut(f6, i, i) negative");

        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, b, c)), -100e6, "muldivOut(f6, f6, f6) negative");

        a = Fixed6.wrap(1_111111);
        int256 bi = 333333;
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, bi, bi)), 1_111111, "muldivOut(f6, i, i) precision");

        b = Fixed6.wrap(333333);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, b, b)), 1_111111, "muldivOut(f6, f6, f6) precision");
    }

    function test_mulDivOutRoundsAwayFromZero() public pure {
        Fixed6 a = Fixed6.wrap(1);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, 21, 10)), 3, "muldivOut(f6, i, i) 1*21/10 = 3");
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, 21, -10)), -3, "muldivOut(f6, i, i) 1*21/-10 = -3");
        a = Fixed6.wrap(-1);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, 21, 10)), -3, "muldivOut(f6, i, i) -1*21/10 = -3");
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, 21, -10)), 3, "muldivOut(f6, i, i) -1*21/-10 = 3");

        a = Fixed6.wrap(1);
        Fixed6 b = Fixed6.wrap(21);
        Fixed6 c = Fixed6.wrap(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, b, c)), 3, "muldivOut(f6, f6, f6) 1*21/10 = 3");
        c = Fixed6.wrap(-10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, b, c)), -3, "muldivOut(f6, f6, f6) 1*21/-10 = -3");
        a = Fixed6.wrap(-1);
        c = Fixed6.wrap(10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, b, c)), -3, "muldivOut(f6, f6, f6) -1*21/10 = -3");
        c = Fixed6.wrap(-10);
        assertEq(Fixed6.unwrap(Fixed6Lib.muldivOut(a, b, c)), 3, "muldivOut(f6, f6, f6) -1*21/-10 = 3");
    }

    function test_mulDivOutSignedRevertsIfDivisorIsZero() public {
        Fixed6 a = Fixed6Lib.from(20);
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.muldivOutSigned(a, 10e6, 0);
    }

    function test_mulDivOutFixedRevertsIfDivisorIsZero() public {
        Fixed6 a = Fixed6Lib.from(20);
        Fixed6 b = Fixed6Lib.from(10);
        Fixed6 c = Fixed6Lib.ZERO;
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.muldivOutFixed(a, b, c);
    }

    function test_equals() public pure {
        Fixed6 a = Fixed6.wrap(12);
        Fixed6 b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.eq(a, b), true, "12 == 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-12);
        assertEq(a == b, true, "-12 == -12");
        a = Fixed6.wrap(11);
        b = Fixed6.wrap(12);
        assertEq(a == b, false, "11 != 12");
    }

    function test_notEquals() public pure {
        Fixed6 a = Fixed6.wrap(12);
        Fixed6 b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.neq(a, b), false, "12 != 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-12);
        assertEq(a != b, false, "-12 != -12");
        a = Fixed6.wrap(11);
        b = Fixed6.wrap(12);
        assertEq(a != b, true, "11 == 12");
    }

    function test_greaterThan() public pure {
        Fixed6 a = Fixed6.wrap(13);
        Fixed6 b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.gt(a, b), true, "13 > 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-13);
        assertEq(Fixed6Lib.gt(a, b), true, "-12 > -13");
        a = Fixed6.wrap(12);
        b = Fixed6.wrap(12);
        assertEq(a > b, false, "12 !> 12");
        a = Fixed6.wrap(11);
        assertEq(a > b, false, "11 !> 12");
    }

    function test_lessThan() public pure {
        Fixed6 a = Fixed6.wrap(13);
        Fixed6 b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.lt(a, b), false, "13 !< 12");
        a = Fixed6.wrap(12);
        assertEq(Fixed6Lib.lt(a, b), false, "12 !< 12");
        a = Fixed6.wrap(11);
        b = Fixed6.wrap(12);
        assertEq(a < b, true, "11 < 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-11);
        assertEq(a < b, true, "-12 < -11");
    }

    function test_greaterThanOrEqualTo() public pure {
        Fixed6 a = Fixed6.wrap(13);
        Fixed6 b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.gte(a, b), true, "13 >= 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-13);
        assertEq(Fixed6Lib.gte(a, b), true, "-12 >= -13");
        a = Fixed6.wrap(12);
        b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.gte(a, b), true, "12 >= 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-12);
        assertEq(a >= b, true, "-12 >= -12");
        a = Fixed6.wrap(11);
        b = Fixed6.wrap(12);
        assertEq(a >= b, false, "11 !>= 12");
    }

    function test_lessThanOrEqualTo() public pure {
        Fixed6 a = Fixed6.wrap(13);
        Fixed6 b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.lte(a, b), false, "13 !<= 12");
        a = Fixed6.wrap(12);
        assertEq(Fixed6Lib.lte(a, b), true, "12 <= 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-12);
        assertEq(Fixed6Lib.lte(a, b), true, "-12 <= -12");
        a = Fixed6.wrap(11);
        b = Fixed6.wrap(12);
        assertEq(a <= b, true, "11 <= 12");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-11);
        assertEq(a <= b, true, "-12 <= -11");
    }

    function test_compare() public pure {
        Fixed6 a = Fixed6.wrap(13);
        Fixed6 b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.compare(a, b), 2, "compare positive (positive arguments)");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-13);
        assertEq(Fixed6Lib.compare(a, b), 2, "compare positive (negative arguments)");
        a = Fixed6.wrap(12);
        b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.compare(a, b), 1, "compare zero");
        a = Fixed6.wrap(11);
        b = Fixed6.wrap(12);
        assertEq(Fixed6Lib.compare(a, b), 0, "compare negative (positive arguments)");
        a = Fixed6.wrap(-12);
        b = Fixed6.wrap(-11);
        assertEq(Fixed6Lib.compare(a, b), 0, "compare negative (negative arguments)");
    }

    function test_ratio() public pure {
        assertEq(Fixed6.unwrap(Fixed6Lib.ratio(2000, 100)), 20e6, "2000/100 = 20");
        assertEq(Fixed6.unwrap(Fixed6Lib.ratio(-2000, -100)), 20e6, "-2000/-100 = 20");
    }

    function test_min() public pure {
        Fixed6 a = Fixed6.wrap(2000);
        Fixed6 b = Fixed6.wrap(100);
        assertEq(Fixed6.unwrap(Fixed6Lib.min(a, b)), 100, "min(2000, 100) = 100");
        a = Fixed6.wrap(-2000);
        b = Fixed6.wrap(-100);
        assertEq(Fixed6.unwrap(Fixed6Lib.min(a, b)), -2000, "min(-2000, -100) = -2000");
        a = Fixed6.wrap(100);
        b = Fixed6.wrap(2000);
        assertEq(Fixed6.unwrap(Fixed6Lib.min(a, b)), 100, "min(100, 2000) = 100");
        a = Fixed6.wrap(-100);
        b = Fixed6.wrap(-2000);
        assertEq(Fixed6.unwrap(Fixed6Lib.min(a, b)), -2000, "min(-100, -2000) = -2000");
    }

    function test_max() public pure {
        Fixed6 a = Fixed6.wrap(2000);
        Fixed6 b = Fixed6.wrap(100);
        assertEq(Fixed6.unwrap(Fixed6Lib.max(a, b)), 2000, "max(2000, 100) = 2000");
        a = Fixed6.wrap(-2000);
        b = Fixed6.wrap(-100);
        assertEq(Fixed6.unwrap(Fixed6Lib.max(a, b)), -100, "max(-2000, -100) = -100");
        a = Fixed6.wrap(100);
        b = Fixed6.wrap(2000);
        assertEq(Fixed6.unwrap(Fixed6Lib.max(a, b)), 2000, "max(100, 2000) = 2000");
        a = Fixed6.wrap(-100);
        b = Fixed6.wrap(-2000);
        assertEq(Fixed6.unwrap(Fixed6Lib.max(a, b)), -100, "max(-100, -2000) = -100");
    }

    function test_truncate() public pure {
        Fixed6 a = Fixed6.wrap(123_456000);
        assertEq(Fixed6Lib.truncate(a), 123, "truncate returns floor (positive)");
        a = Fixed6.wrap(-123_456000);
        assertEq(Fixed6Lib.truncate(a), -123, "truncate returns floor (negative)");
    }

    function test_sign() public pure {
        assertEq(Fixed6Lib.sign(Fixed6.wrap(12)), 1, "sign positive number");
        assertEq(Fixed6Lib.sign(Fixed6.wrap(0)), 0, "sign zero");
        assertEq(Fixed6Lib.sign(Fixed6.wrap(-12)), -1, "sign negative number");
    }

    function test_abs() public pure {
        Fixed6 a = Fixed6.wrap(12);
        assertEq(UFixed6.unwrap(Fixed6Lib.abs(a)), 12, "abs positive number");
        a = Fixed6.wrap(0);
        assertEq(UFixed6.unwrap(Fixed6Lib.abs(a)), 0, "abs zero");
        a = Fixed6.wrap(-12);
        assertEq(UFixed6.unwrap(Fixed6Lib.abs(a)), 12, "abs negative number");
    }

    function test_inside() public pure {
        Fixed6 a = Fixed6.wrap(12);
        Fixed6 b = Fixed6.wrap(10);
        Fixed6 c = Fixed6.wrap(15);
        assertEq(Fixed6Lib.inside(a, b, c), true, "inside");
        a = Fixed6.wrap(10);
        assertEq(Fixed6Lib.inside(a, b, c), true, "on lower bound");
        a = Fixed6.wrap(15);
        assertEq(Fixed6Lib.inside(a, b, c), true, "on upper bound");
        a = Fixed6.wrap(9);
        assertEq(Fixed6Lib.inside(a, b, c), false, "below lower bound");
        a = Fixed6.wrap(16);
        assertEq(Fixed6Lib.inside(a, b, c), false, "above upper bound");
    }

    function test_outside() public pure {
        Fixed6 a = Fixed6.wrap(12);
        Fixed6 b = Fixed6.wrap(10);
        Fixed6 c = Fixed6.wrap(15);
        assertEq(Fixed6Lib.outside(a, b, c), false, "inside");
        a = Fixed6.wrap(10);
        assertEq(Fixed6Lib.outside(a, b, c), false, "on lower bound");
        a = Fixed6.wrap(15);
        assertEq(Fixed6Lib.outside(a, b, c), false, "on upper bound");
        a = Fixed6.wrap(9);
        assertEq(Fixed6Lib.outside(a, b, c), true, "below lower bound");
        a = Fixed6.wrap(16);
        assertEq(Fixed6Lib.outside(a, b, c), true, "above upper bound");
    }

    function test_store() public {
        Fixed6Storage SLOT = Fixed6Storage.wrap(keccak256("equilibria.root.Fixed6.testSlot"));
        Fixed6StorageLib.store(SLOT, Fixed6.wrap(-12));
        assertEq(Fixed6.unwrap(SLOT.read()), -12, "stored and loaded");
    }
}

contract MockFixed6 {
    function from(UFixed6 a) external pure returns (Fixed6) {
        return Fixed6Lib.from(a);
    }

    function from(int256 s, UFixed6 m) external pure returns (Fixed6) {
        return Fixed6Lib.from(s, m);
    }

    function from(int256 a) external pure returns (Fixed6) {
        return Fixed6Lib.from(a);
    }

    function fromFixed18(Fixed18 a) external pure returns (Fixed6) {
        return Fixed6Lib.from(a);
    }

    function fromSignificandAndExponent(Fixed6 significand, int256 exponent) external pure returns (Fixed6) {
        return Fixed6Lib.from(significand, exponent);
    }

    function div(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.div(a, b);
    }

    function divOut(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.divOut(a, b);
    }

    function unsafeDiv(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.unsafeDiv(a, b);
    }

    function unsafeDivOut(Fixed6 a, Fixed6 b) external pure returns (Fixed6) {
        return Fixed6Lib.unsafeDivOut(a, b);
    }

    function muldivSigned(Fixed6 a, int256 b, int256 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldiv(a, b, c);
    }

    function muldivFixed(Fixed6 a, Fixed6 b, Fixed6 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldiv(a, b, c);
    }

    function muldivOutSigned(Fixed6 a, int256 b, int256 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldivOut(a, b, c);
    }

    function muldivOutFixed(Fixed6 a, Fixed6 b, Fixed6 c) external pure returns (Fixed6) {
        return Fixed6Lib.muldivOut(a, b, c);
    }
}
