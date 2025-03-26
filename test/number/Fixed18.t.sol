// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { Test } from "forge-std/Test.sol";

import { Fixed18, Fixed18Lib, Fixed18Storage, Fixed18StorageLib } from "../../src/number/types/Fixed18.sol";
import { UFixed18, UFixed18Lib } from "../../src/number/types/UFixed18.sol";
import { Fixed6, Fixed6Lib } from "../../src/number/types/Fixed6.sol";
import { NumberMath } from "../../src/number/NumberMath.sol";

contract Fixed18Test is Test {
    MockFixed18 m = new MockFixed18();
    uint256 constant TOO_LARGE_UNSIGNED = 2 ** 256 - 10;
    int256 constant TOO_LARGE_SIGNED = type(int256).max - 10;

    function test_constants() public pure {
        assertEq(Fixed18.unwrap(Fixed18Lib.ZERO), 0);
        assertEq(Fixed18.unwrap(Fixed18Lib.ONE), 1e18);
        assertEq(Fixed18.unwrap(Fixed18Lib.NEG_ONE), -1e18);
        assertEq(Fixed18.unwrap(Fixed18Lib.MAX), type(int256).max);
        assertEq(Fixed18.unwrap(Fixed18Lib.MIN), type(int256).min);
    }

    function test_fromSigned() public pure {
        Fixed18 f18 = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(f18), 10e18);
    }

    function test_fromSignedRevertsIfTooLarge() public {
        // cannot test panics directly from library
        vm.expectRevert(stdError.arithmeticError);
        m.from(TOO_LARGE_SIGNED);
    }

    function test_fromUnsignedWithSign() public pure {
        int256 ten = 10e18;
        UFixed18 ten_u18 = UFixed18Lib.from(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.from(int(1), ten_u18)), int(ten), "Creates positive");
        assertEq(Fixed18.unwrap(Fixed18Lib.from(int(0), ten_u18)), 0, "Creates zero");
        assertEq(Fixed18.unwrap(Fixed18Lib.from(-1, ten_u18)), int(-ten), "Creates negative");
    }

    function test_fromUnsignedWithSignRevertsIfTooLarge() public {
        UFixed18 too_large = UFixed18.wrap(TOO_LARGE_UNSIGNED);
        // cannot test reverts directly from library
        vm.expectRevert(abi.encodeWithSelector(Fixed18Lib.Fixed18OverflowError.selector, TOO_LARGE_UNSIGNED));
        m.from(1, too_large);
    }

    function test_fromUnsignedWithSignRevertsIfTooSmall() public {
        UFixed18 too_large = UFixed18.wrap(TOO_LARGE_UNSIGNED);
        vm.expectRevert(abi.encodeWithSelector(Fixed18Lib.Fixed18OverflowError.selector, TOO_LARGE_UNSIGNED));
        m.from(-1, too_large);
    }

    function test_fromUnsignedWithoutSign() public pure {
        UFixed18 ten_u18 = UFixed18Lib.from(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.from(ten_u18)), int(10e18), "Creates from UFixed18");
    }

    function test_fromUnsignedWithoutSignRevertsIfTooLarge() public {
        UFixed18 too_large = UFixed18.wrap(TOO_LARGE_UNSIGNED);
        vm.expectRevert(abi.encodeWithSelector(Fixed18Lib.Fixed18OverflowError.selector, TOO_LARGE_UNSIGNED));
        m.from(too_large);
    }

    function test_fromFixed6() public view {
        Fixed6 ten_f6 = Fixed6Lib.from(10);
        assertEq(Fixed18.unwrap(m.fromFixed6(ten_f6)), int(10e18));
    }

    function test_fromFixed6RevertsIfTooLarge() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromFixed6(Fixed6.wrap(TOO_LARGE_SIGNED));
    }

    function test_fromSignificantAndExponent() public pure {
        Fixed18 ten_pow_2 = Fixed18Lib.from(Fixed18Lib.from(10), 2);
        assertEq(Fixed18.unwrap(ten_pow_2), 10e20, "10^2");
        Fixed18 neg_ten_pow_2 = Fixed18Lib.from(Fixed18Lib.from(-10), 2);
        assertEq(Fixed18.unwrap(neg_ten_pow_2), -10e20, "-10^2");

        Fixed18 ten_pow_neg2 = Fixed18Lib.from(Fixed18Lib.from(10), -2);
        assertEq(Fixed18.unwrap(ten_pow_neg2), 10e16, "10^-2");
        Fixed18 neg_ten_pow_neg2 = Fixed18Lib.from(Fixed18Lib.from(-10), -2);
        assertEq(Fixed18.unwrap(neg_ten_pow_neg2), -10e16, "-10^-2");

        assertEq(Fixed18.unwrap(Fixed18Lib.from(Fixed18Lib.ZERO, 18)), 0, "0^18");
        assertEq(Fixed18.unwrap(Fixed18Lib.from(Fixed18Lib.ZERO, 0)), 0, "0^0");

        Fixed18 ten_pow_0 = Fixed18Lib.from(Fixed18Lib.from(10), 0);
        assertEq(Fixed18.unwrap(ten_pow_0), 10e18, "10^0");
        Fixed18 neg_ten_pow_0 = Fixed18Lib.from(Fixed18Lib.from(-10), 0);
        assertEq(Fixed18.unwrap(neg_ten_pow_0), -10e18, "-10^0");

        Fixed18 LARGE_SIGNIFICAND = Fixed18.wrap(1e40);
        assertEq(Fixed18.unwrap(Fixed18Lib.from(LARGE_SIGNIFICAND, 1)), 1e41);
        assertEq(Fixed18.unwrap(Fixed18Lib.from(LARGE_SIGNIFICAND, -1)), 1e39);
    }

    function test_fromSignificantAndExponentRevertsIfTooLarge() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(Fixed18Lib.ONE, type(int256).max);
    }

    function test_fromSignificantAndExponentRevertsIfTooSmall() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(Fixed18Lib.ONE, type(int256).min + 1);
    }

    function test_isZero() public pure {
        assertEq(Fixed18Lib.isZero(Fixed18Lib.ZERO), true, "0 is zero");
        assertEq(Fixed18Lib.isZero(Fixed18Lib.ONE), false, "1 is not zero");
        assertEq(Fixed18Lib.isZero(Fixed18Lib.NEG_ONE), false, "-1 is not zero");
    }

    function test_addition() public pure {
        Fixed18 a = Fixed18Lib.from(10);
        Fixed18 b = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(Fixed18Lib.add(a, b)), 30e18, "10 + 20 = 30");

        a = Fixed18Lib.from(-10);
        b = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(Fixed18Lib.add(a, b)), -30e18, "-10 + -20 = -30");
    }

    function test_subtraction() public pure {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.sub(a, b)), 10e18, "20 - 10 = 10");

        a = Fixed18Lib.from(-20);
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.sub(a, b)), -10e18, "-20 - -10 = -10");
    }

    function test_multiplication() public pure {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), 200e18, "20 * 10 = 200");
        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), -200e18, "-20 * 10 = -200");
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), 200e18, "-20 * -10 = 200");
        a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), -200e18, "20 * -10 = -200");
    }

    function test_MultiplicationRoundsTowardZero() public pure {
        Fixed18 a = Fixed18.wrap(1);
        Fixed18 b = Fixed18.wrap(2);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), 0, "0.000000000_000000001 * 0.000000000_000000002 = 0");
        a = Fixed18.wrap(-1);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), 0, "-0.000000000_000000001 * 0.000000000_000000002 = 0");
        b = Fixed18.wrap(-2);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), 0, "-0.000000000_000000001 * -0.000000000_000000002 = 0");
        a = Fixed18.wrap(1);
        assertEq(Fixed18.unwrap(Fixed18Lib.mul(a, b)), 0, "0.000000000_000000001 * -0.000000000_000000002 = 0");
    }

    function test_multiplicationOut() public pure {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), 200e18, "20 * 10 = 200");
        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), -200e18, "-20 * 10 = -200");
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), 200e18, "-20 * -10 = 200");
        a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), -200e18, "20 * -10 = -200");
    }

    function test_multiplicationOutRoundsAwayFromZero() public pure {
        Fixed18 a = Fixed18.wrap(1);
        Fixed18 b = Fixed18.wrap(2);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), 1, "0.000000000_000000001 * 0.000000000_000000002 = 0.000000000_000000001");
        a = Fixed18.wrap(-1);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), -1, "-0.000000000_000000001 * 0.000000000_000000002 = -0.000000000_000000001");
        b = Fixed18.wrap(-2);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), 1, "-0.000000000_000000001 * -0.000000000_000000002 = 0.000000000_000000001");
        a = Fixed18.wrap(1);
        assertEq(Fixed18.unwrap(Fixed18Lib.mulOut(a, b)), -1, "0.000000000_000000001 * -0.000000000_000000002 = -0.000000000_000000001");
    }

    function test_division() public pure {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.div(a, b)), 2e18, "20 / 10 = 2");
        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(Fixed18Lib.div(a, b)), -2e18, "-20 / 10 = -2");
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.div(a, b)), 2e18, "-20 / -10 = 2");
        a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(Fixed18Lib.div(a, b)), -2e18, "20 / -10 = -2");
    }

    function test_divisionRoundsTowardsZero() public pure {
        Fixed18 a = Fixed18.wrap(21);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.div(a, b)), 2, "0.000000000_000000021 / 0.000000000_000000010 = 2");
        a = Fixed18.wrap(-21);
        assertEq(Fixed18.unwrap(Fixed18Lib.div(a, b)), -2, "-0.000000000_000000021 / 0.000000000_000000010 = -2");
    }

    function test_divisionZeroByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(Fixed18Lib.ZERO, Fixed18Lib.ZERO);
    }

    function test_divisionPositiveByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(Fixed18Lib.from(20), Fixed18Lib.ZERO);
    }

    function test_divisionNegativeByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(Fixed18Lib.from(-20), Fixed18Lib.ZERO);
    }

    function test_divisionOutWithoutRounding() public view {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), 2e18, "20 / 10 = 2");
        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), -2e18, "-20 / 10 = -2");
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), 2e18, "-20 / -10 = 2");
        a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), -2e18, "20 / -10 = -2");
    }

    function test_divisionRoundsAwayFromZero() public view {
        Fixed18 a = Fixed18.wrap(21);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), 3, "0.000000000_000000021 / 10 = 0.000000000_000000003");
        a = Fixed18.wrap(-21);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), -3, "-0.000000000_000000021 / 10 = -0.000000000_000000003");
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), 3, "-0.000000000_000000021 / -10 = 0.000000000_000000003");
        a = Fixed18.wrap(21);
        assertEq(Fixed18.unwrap(m.divOut(a, b)), -3, "0.000000000_000000021 / -10 = -0.000000000_000000003");
    }

    function test_divisionOutZeroByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(Fixed18Lib.ZERO, Fixed18Lib.ZERO);
    }

    function test_divisionOutPositiveByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(Fixed18Lib.from(20), Fixed18Lib.ZERO);
    }

    function test_divisionOutNegativeByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(Fixed18Lib.from(-20), Fixed18Lib.ZERO);
    }

    function test_unsafeDivision() public view {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(m.unsafeDiv(a, b)), 2e18, "20 / 10 = 2");
        a = Fixed18Lib.from(-20);
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(m.unsafeDiv(a, b)), 2e18, "-20 / -10 = 2");

        a = Fixed18.wrap(21);
        b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(m.unsafeDiv(a, b)), 2, "divides and floors");

        a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(m.unsafeDiv(a, Fixed18Lib.ZERO)), type(int256).max, "20 / 0 = MaxInt");
        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(m.unsafeDiv(a, Fixed18Lib.ZERO)), type(int256).min, "-20 / 0 = MinInt");
    }

    function test_unsafeDivisionOut() public view {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(m.unsafeDivOut(a, b)), 2e18, "20 / 10 = 2");
        a = Fixed18Lib.from(-20);
        b = Fixed18Lib.from(-10);
        assertEq(Fixed18.unwrap(m.unsafeDivOut(a, b)), 2e18, "-20 / -10 = 2");

        a = Fixed18.wrap(21);
        b = Fixed18Lib.from(10);
        assertEq(Fixed18.unwrap(m.unsafeDivOut(a, b)), 3, "divides and ceils");

        assertEq(Fixed18.unwrap(m.unsafeDivOut(Fixed18Lib.ZERO, Fixed18Lib.ZERO)), 1e18, "0 / 0 = 1");
        a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(m.unsafeDiv(a, Fixed18Lib.ZERO)), type(int256).max, "20 / 0 = MaxInt");
        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(m.unsafeDivOut(a, Fixed18Lib.ZERO)), type(int256).min, "-20 / 0 = MinInt");
    }

    function test_mulDiv() public pure {
        Fixed18 a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, int(10e18), int(2e18))), 100e18, "muldiv(Fixed18, int256, int256) positive");

        Fixed18 b = Fixed18Lib.from(10);
        Fixed18 c = Fixed18Lib.from(2);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, b, c)), 100e18, "muldiv(f18, i, i) positive");

        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, 10e18, 2e18)), -100e18, "muldiv(f18, i, i) negative");

        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, b, c)), -100e18, "muldiv(18, f18, f18) negative");

        a = Fixed18.wrap(1_111111111_111111111);
        b = Fixed18.wrap(33333333_3333333333);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, b, b)), 1_111111111_111111111, "muldiv(18, f18, f18) precision");
    }

    function test_mulDivRoundsTowardsZero() public pure {
        Fixed18 a = Fixed18.wrap(1);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, 21, 10)), 2, "muldiv(f18, i, i) 1*21/10 = 2");
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, 21, -10)), -2, "muldiv(f18, i, i) 1*21/-10 = -2");
        a = Fixed18.wrap(-1);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, 21, 10)), -2, "muldiv(f18, i, i) -1*21/10 = -2");
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, 21, -10)), 2, "muldiv(f18, i, i) -1*21/-10 = 2");

        a = Fixed18.wrap(1);
        Fixed18 b = Fixed18.wrap(21);
        Fixed18 c = Fixed18.wrap(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, b, c)), 2, "muldiv(f18, f18, f18) 1*21/10 = 2");
        c = Fixed18.wrap(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, b, c)), -2, "muldiv(f18, f18, f18) 1*21/-10 = -2");
        a = Fixed18.wrap(-1);
        c = Fixed18.wrap(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, b, c)), -2, "muldiv(f18, f18, f18) -1*21/10 = -2");
        c = Fixed18.wrap(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldiv(a, b, c)), 2, "muldiv(f18, f18, f18) -1*21/-10 = 2");
    }

    function test_mulDivSignedRevertsIfDivisorIsZero() public {
        Fixed18 a = Fixed18Lib.from(20);
        vm.expectRevert(stdError.divisionError);
        m.muldivSigned(a, 10e18, 0);
    }

    function test_mulDivFixedRevertsIfDivisorIsZero() public {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        Fixed18 c = Fixed18Lib.ZERO;
        vm.expectRevert(stdError.divisionError);
        m.muldivFixed(a, b, c);
    }

    function test_mulDivOut() public pure {
        Fixed18 a = Fixed18Lib.from(20);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, 10e18, 2e18)), 100e18, "muldivOut(f18, i, i) positive");

        Fixed18 b = Fixed18Lib.from(10);
        Fixed18 c = Fixed18Lib.from(2);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, b, c)), 100e18, "muldivOut(f18, f18, f18) positive");

        a = Fixed18Lib.from(-20);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, 10e18, 2e18)), -100e18, "muldivOut(f18, i, i) negative");

        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, b, c)), -100e18, "muldivOut(f18, f18, f18) negative");

        a = Fixed18.wrap(1_111111111_111111111);
        int256 bi = 33333333_3333333333;
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, bi, bi)), 1_111111111_111111111, "muldivOut(f18, i, i) precision");

        b = Fixed18.wrap(33333333_3333333333);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, b, b)), 1_111111111_111111111, "muldivOut(f18, f18, f18) precision");
    }

    function test_mulDivOutRoundsAwayFromZero() public pure {
        Fixed18 a = Fixed18.wrap(1);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, 21, 10)), 3, "muldivOut(f18, i, i) 1*21/10 = 3");
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, 21, -10)), -3, "muldivOut(f18, i, i) 1*21/-10 = -3");
        a = Fixed18.wrap(-1);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, 21, 10)), -3, "muldivOut(f18, i, i) -1*21/10 = -3");
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, 21, -10)), 3, "muldivOut(f18, i, i) -1*21/-10 = 3");

        a = Fixed18.wrap(1);
        Fixed18 b = Fixed18.wrap(21);
        Fixed18 c = Fixed18.wrap(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, b, c)), 3, "muldivOut(f18, f18, f18) 1*21/10 = 3");
        c = Fixed18.wrap(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, b, c)), -3, "muldivOut(f18, f18, f18) 1*21/-10 = -3");
        a = Fixed18.wrap(-1);
        c = Fixed18.wrap(10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, b, c)), -3, "muldivOut(f18, f18, f18) -1*21/10 = -3");
        c = Fixed18.wrap(-10);
        assertEq(Fixed18.unwrap(Fixed18Lib.muldivOut(a, b, c)), 3, "muldivOut(f18, f18, f18) -1*21/-10 = 3");
    }

    function test_mulDivOutSignedRevertsIfDivisorIsZero() public {
        Fixed18 a = Fixed18Lib.from(20);
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.muldivOutSigned(a, 10e18, 0);
    }

    function test_mulDivOutFixedRevertsIfDivisorIsZero() public {
        Fixed18 a = Fixed18Lib.from(20);
        Fixed18 b = Fixed18Lib.from(10);
        Fixed18 c = Fixed18Lib.ZERO;
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.muldivOutFixed(a, b, c);
    }

    function test_equals() public pure {
        Fixed18 a = Fixed18.wrap(12);
        Fixed18 b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.eq(a, b), true, "12 == 12");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-12);
        assertEq(Fixed18Lib.eq(a, b), true, "-12 == -12");
        a = Fixed18.wrap(11);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.eq(a, b), false, "11 != 12");
    }

    function test_greaterThan() public pure {
        Fixed18 a = Fixed18.wrap(13);
        Fixed18 b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.gt(a, b), true, "13 > 12");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-13);
        assertEq(Fixed18Lib.gt(a, b), true, "-12 > -13");
        a = Fixed18.wrap(12);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.gt(a, b), false, "12 !> 12");
        a = Fixed18.wrap(11);
        assertEq(Fixed18Lib.gt(a, b), false, "11 !> 12");
    }

    function test_lessThan() public pure {
        Fixed18 a = Fixed18.wrap(13);
        Fixed18 b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.lt(a, b), false, "13 !< 12");
        a = Fixed18.wrap(12);
        assertEq(Fixed18Lib.lt(a, b), false, "12 !< 12");
        a = Fixed18.wrap(11);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.lt(a, b), true, "11 < 12");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-11);
        assertEq(Fixed18Lib.lt(a, b), true, "-12 < -11");
    }

    function test_greaterThanOrEqualTo() public pure {
        Fixed18 a = Fixed18.wrap(13);
        Fixed18 b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.gte(a, b), true, "13 >= 12");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-13);
        assertEq(Fixed18Lib.gte(a, b), true, "-12 >= -13");
        a = Fixed18.wrap(12);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.gte(a, b), true, "12 >= 12");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-12);
        assertEq(Fixed18Lib.gte(a, b), true, "-12 >= -12");
        a = Fixed18.wrap(11);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.gte(a, b), false, "11 !>= 12");
    }

    function test_lessThanOrEqualTo() public pure {
        Fixed18 a = Fixed18.wrap(13);
        Fixed18 b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.lte(a, b), false, "13 !<= 12");
        a = Fixed18.wrap(12);
        assertEq(Fixed18Lib.lte(a, b), true, "12 <= 12");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-12);
        assertEq(Fixed18Lib.lte(a, b), true, "-12 <= -12");
        a = Fixed18.wrap(11);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.lte(a, b), true, "11 <= 12");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-11);
        assertEq(Fixed18Lib.lte(a, b), true, "-12 <= -11");
    }

    function test_compare() public pure {
        Fixed18 a = Fixed18.wrap(13);
        Fixed18 b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.compare(a, b), 2, "compare positive (positive arguments)");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-13);
        assertEq(Fixed18Lib.compare(a, b), 2, "compare positive (negative arguments)");
        a = Fixed18.wrap(12);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.compare(a, b), 1, "compare zero");
        a = Fixed18.wrap(11);
        b = Fixed18.wrap(12);
        assertEq(Fixed18Lib.compare(a, b), 0, "compare negative (positive arguments)");
        a = Fixed18.wrap(-12);
        b = Fixed18.wrap(-11);
        assertEq(Fixed18Lib.compare(a, b), 0, "compare negative (negative arguments)");
    }

    function test_ratio() public pure {
        assertEq(Fixed18.unwrap(Fixed18Lib.ratio(2000, 100)), 20e18, "2000/100 = 20");
        assertEq(Fixed18.unwrap(Fixed18Lib.ratio(-2000, -100)), 20e18, "-2000/-100 = 20");
    }

    function test_min() public pure {
        Fixed18 a = Fixed18.wrap(2000);
        Fixed18 b = Fixed18.wrap(100);
        assertEq(Fixed18.unwrap(Fixed18Lib.min(a, b)), 100, "min(2000, 100) = 100");
        a = Fixed18.wrap(-2000);
        b = Fixed18.wrap(-100);
        assertEq(Fixed18.unwrap(Fixed18Lib.min(a, b)), -2000, "min(-2000, -100) = -2000");
        a = Fixed18.wrap(100);
        b = Fixed18.wrap(2000);
        assertEq(Fixed18.unwrap(Fixed18Lib.min(a, b)), 100, "min(100, 2000) = 100");
        a = Fixed18.wrap(-100);
        b = Fixed18.wrap(-2000);
        assertEq(Fixed18.unwrap(Fixed18Lib.min(a, b)), -2000, "min(-100, -2000) = -2000");
    }

    function test_max() public pure {
        Fixed18 a = Fixed18.wrap(2000);
        Fixed18 b = Fixed18.wrap(100);
        assertEq(Fixed18.unwrap(Fixed18Lib.max(a, b)), 2000, "max(2000, 100) = 2000");
        a = Fixed18.wrap(-2000);
        b = Fixed18.wrap(-100);
        assertEq(Fixed18.unwrap(Fixed18Lib.max(a, b)), -100, "max(-2000, -100) = -100");
        a = Fixed18.wrap(100);
        b = Fixed18.wrap(2000);
        assertEq(Fixed18.unwrap(Fixed18Lib.max(a, b)), 2000, "max(100, 2000) = 2000");
        a = Fixed18.wrap(-100);
        b = Fixed18.wrap(-2000);
        assertEq(Fixed18.unwrap(Fixed18Lib.max(a, b)), -100, "max(-100, -2000) = -100");
    }

    function test_truncate() public pure {
        Fixed18 a = Fixed18.wrap(123_456000000_000000000);
        assertEq(Fixed18Lib.truncate(a), 123, "truncate returns floor (positive)");
        a = Fixed18.wrap(-123_456000000_000000000);
        assertEq(Fixed18Lib.truncate(a), -123, "truncate returns floor (negative)");
    }

    function test_sign() public pure {
        assertEq(Fixed18Lib.sign(Fixed18.wrap(12)), 1, "sign positive number");
        assertEq(Fixed18Lib.sign(Fixed18.wrap(0)), 0, "sign zero");
        assertEq(Fixed18Lib.sign(Fixed18.wrap(-12)), -1, "sign negative number");
    }

    function test_abs() public pure {
        Fixed18 a = Fixed18.wrap(12);
        assertEq(UFixed18.unwrap(Fixed18Lib.abs(a)), 12, "abs positive number");
        a = Fixed18.wrap(0);
        assertEq(UFixed18.unwrap(Fixed18Lib.abs(a)), 0, "abs zero");
        a = Fixed18.wrap(-12);
        assertEq(UFixed18.unwrap(Fixed18Lib.abs(a)), 12, "abs negative number");
    }

    function test_inside() public pure {
        Fixed18 a = Fixed18.wrap(12);
        Fixed18 b = Fixed18.wrap(10);
        Fixed18 c = Fixed18.wrap(15);
        assertEq(Fixed18Lib.inside(a, b, c), true, "inside");
        a = Fixed18.wrap(10);
        assertEq(Fixed18Lib.inside(a, b, c), true, "on lower bound");
        a = Fixed18.wrap(15);
        assertEq(Fixed18Lib.inside(a, b, c), true, "on upper bound");
        a = Fixed18.wrap(9);
        assertEq(Fixed18Lib.inside(a, b, c), false, "below lower bound");
        a = Fixed18.wrap(16);
        assertEq(Fixed18Lib.inside(a, b, c), false, "above upper bound");
    }

    function test_outside() public pure {
        Fixed18 a = Fixed18.wrap(12);
        Fixed18 b = Fixed18.wrap(10);
        Fixed18 c = Fixed18.wrap(15);
        assertEq(Fixed18Lib.outside(a, b, c), false, "inside");
        a = Fixed18.wrap(10);
        assertEq(Fixed18Lib.outside(a, b, c), false, "on lower bound");
        a = Fixed18.wrap(15);
        assertEq(Fixed18Lib.outside(a, b, c), false, "on upper bound");
        a = Fixed18.wrap(9);
        assertEq(Fixed18Lib.outside(a, b, c), true, "below lower bound");
        a = Fixed18.wrap(16);
        assertEq(Fixed18Lib.outside(a, b, c), true, "above upper bound");
    }

    function test_store() public {
        Fixed18Storage SLOT = Fixed18Storage.wrap(keccak256("equilibria.root.Fixed18.testSlot"));
        Fixed18StorageLib.store(SLOT, Fixed18.wrap(-12));
        assertEq(Fixed18.unwrap(SLOT.read()), -12, "stored and loaded");
    }
}

contract MockFixed18 {
    function from(UFixed18 a) external pure returns (Fixed18) {
        return Fixed18Lib.from(a);
    }

    function from(int256 s, UFixed18 m) external pure returns (Fixed18) {
        return Fixed18Lib.from(s, m);
    }

    function from(int256 a) external pure returns (Fixed18) {
        return Fixed18Lib.from(a);
    }

    function fromFixed6(Fixed6 a) external pure returns (Fixed18) {
        return Fixed18Lib.from(a);
    }

    function fromSignificandAndExponent(Fixed18 significand, int256 exponent) external pure returns (Fixed18) {
        return Fixed18Lib.from(significand, exponent);
    }

    function div(Fixed18 a, Fixed18 b) external pure returns (Fixed18) {
        return Fixed18Lib.div(a, b);
    }

    function divOut(Fixed18 a, Fixed18 b) external pure returns (Fixed18) {
        return Fixed18Lib.divOut(a, b);
    }

    function unsafeDiv(Fixed18 a, Fixed18 b) external pure returns (Fixed18) {
        return Fixed18Lib.unsafeDiv(a, b);
    }

    function unsafeDivOut(Fixed18 a, Fixed18 b) external pure returns (Fixed18) {
        return Fixed18Lib.unsafeDivOut(a, b);
    }

    function muldivSigned(Fixed18 a, int256 b, int256 c) external pure returns (Fixed18) {
        return Fixed18Lib.muldiv(a, b, c);
    }

    function muldivFixed(Fixed18 a, Fixed18 b, Fixed18 c) external pure returns (Fixed18) {
        return Fixed18Lib.muldiv(a, b, c);
    }

    function muldivOutSigned(Fixed18 a, int256 b, int256 c) external pure returns (Fixed18) {
        return Fixed18Lib.muldivOut(a, b, c);
    }

    function muldivOutFixed(Fixed18 a, Fixed18 b, Fixed18 c) external pure returns (Fixed18) {
        return Fixed18Lib.muldivOut(a, b, c);
    }
}
