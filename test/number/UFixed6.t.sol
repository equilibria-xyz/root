// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { Test } from "forge-std/Test.sol";

import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";
import { UFixed18, UFixed18Lib } from "../../src/number/types/UFixed18.sol";
import { Fixed6, Fixed6Lib } from "../../src/number/types/Fixed6.sol";
import { NumberMath } from "../../src/number/NumberMath.sol";

contract UFixed6Test is Test {
    MockUFixed6 m = new MockUFixed6();

    function test_constants() public pure {
        assertEq(UFixed6.unwrap(UFixed6Lib.ZERO), 0);
        assertEq(UFixed6.unwrap(UFixed6Lib.ONE), 1e6);
        assertEq(UFixed6.unwrap(UFixed6Lib.MAX), type(uint256).max);
    }

    function test_from() public pure {
        UFixed6 uf6 = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(uf6), 10e6);
    }

    function test_fromFixed6() public pure {
        Fixed6 ten_f6 = Fixed6Lib.from(10);
        assertEq(UFixed6.unwrap(UFixed6Lib.from(ten_f6)), 10e6);
    }

    function test_unsafeFromFixed6() public pure {
        Fixed6 a = Fixed6.wrap(-1);
        assertEq(UFixed6.unwrap(UFixed6Lib.unsafeFrom(a)), 0);

        Fixed6 b = Fixed6.wrap(1);
        assertEq(UFixed6.unwrap(UFixed6Lib.unsafeFrom(b)), 1);
    }

    function test_fromFixed6RevertsIfLessThanZero() public {
        Fixed6 a = Fixed6.wrap(-1);
        vm.expectRevert(abi.encodeWithSelector(UFixed6Lib.UFixed6UnderflowError.selector, -1));
        m.from(a);
    }

    function test_fromUFixed18() public pure {
        UFixed18 ten_u18 = UFixed18Lib.from(10);
        assertEq(UFixed6.unwrap(UFixed6Lib.from(ten_u18)), 10e6);
    }

    function test_fromUFixed18RoundsTowardZero() public pure {
        UFixed18 a = UFixed18.wrap(1e11);
        assertEq(UFixed6.unwrap(UFixed6Lib.from(a)), 0);
        assertEq(UFixed6.unwrap(UFixed6Lib.from(a, false)), 0);
    }

    function test_fromUFixed18RoundsAwayFromZero() public pure {
        UFixed18 a = UFixed18.wrap(1);
        assertEq(UFixed6.unwrap(UFixed6Lib.from(a, true)), 1);
    }

    function test_fromSignificantAndExponent() public pure {
        UFixed6 ten_pow_2 = UFixed6Lib.from(UFixed6Lib.from(10), 2);
        assertEq(UFixed6.unwrap(ten_pow_2), 10e8, "10^2");

        UFixed6 ten_pow_neg2 = UFixed6Lib.from(UFixed6Lib.from(10), -2);
        assertEq(UFixed6.unwrap(ten_pow_neg2), 10e4, "10^-2");

        assertEq(UFixed6.unwrap(UFixed6Lib.from(UFixed6Lib.ZERO, 6)), 0, "0^6");
        assertEq(UFixed6.unwrap(UFixed6Lib.from(UFixed6Lib.ZERO, 0)), 0, "0^0");

        UFixed6 ten_pow_0 = UFixed6Lib.from(UFixed6Lib.from(10), 0);
        assertEq(UFixed6.unwrap(ten_pow_0), 10e6, "10^0");

        UFixed6 LARGE_SIGNIFICAND = UFixed6.wrap(1e40);
        assertEq(UFixed6.unwrap(UFixed6Lib.from(LARGE_SIGNIFICAND, 1)), 1e41);
        assertEq(UFixed6.unwrap(UFixed6Lib.from(LARGE_SIGNIFICAND, -1)), 1e39);
    }

    function test_fromSignificantAndExponentRevertsIfTooLarge() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(UFixed6Lib.ONE, type(int256).max);
    }

    function test_fromSignificantAndExponentRevertsIfTooSmall() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(UFixed6Lib.ONE, type(int256).min + 1);
    }

    function test_isZero() public pure {
        assertEq(UFixed6Lib.ZERO.isZero(), true, "0 is zero");
        assertEq(UFixed6Lib.ONE.isZero(), false, "1 is not zero");
    }

    function test_addition() public pure {
        UFixed6 a = UFixed6Lib.from(10);
        UFixed6 b = UFixed6Lib.from(20);
        assertEq(UFixed6.unwrap(a + b), 30e6, "10 + 20 = 30");
    }

    function test_subtraction() public pure {
        UFixed6 a = UFixed6Lib.from(20);
        UFixed6 b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(a - b), 10e6, "20 - 10 = 10");
    }

    function test_subtractionRevertsIfNegative() public {
        UFixed6 a = UFixed6Lib.from(10);
        UFixed6 b = UFixed6Lib.from(20);
        vm.expectRevert(stdError.arithmeticError);
        m.sub(a, b);
    }

    function test_unsafeSubtraction() public pure {
        UFixed6 a = UFixed6Lib.from(10);
        UFixed6 b = UFixed6Lib.from(20);
        assertEq(UFixed6.unwrap(a.unsafeSub(b)), 0);

        a = UFixed6Lib.from(30);
        assertEq(UFixed6.unwrap(a.unsafeSub(b)), 10e6);
    }

    function test_multiplication() public pure {
        UFixed6 a = UFixed6Lib.from(20);
        UFixed6 b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(a * b), 200e6, "20 * 10 = 200");
    }

    function test_MultiplicationRoundsTowardZero() public pure {
        UFixed6 a = UFixed6.wrap(1);
        UFixed6 b = UFixed6.wrap(2);
        assertEq(UFixed6.unwrap(a * b), 0, "0.0000001 * 0.0000002 = 0");
    }

    function test_multiplicationOut() public pure {
        UFixed6 a = UFixed6Lib.from(20);
        UFixed6 b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(a.mulOut(b)), 200e6, "20 * 10 = 200");
    }

    function test_multiplicationOutRoundsAwayFromZero() public pure {
        UFixed6 a = UFixed6.wrap(1);
        UFixed6 b = UFixed6.wrap(2);
        assertEq(UFixed6.unwrap(a.mulOut(b)), 1, "0.0000001 * 0.0000002 = 0.0000001");
    }

    function test_division() public pure {
        UFixed6 a = UFixed6.wrap(20);
        UFixed6 b = UFixed6.wrap(10);
        assertEq(UFixed6.unwrap(a / b), 2e6, "20 / 10 = 2");
    }

    function test_divisionRoundsTowardsZero() public pure {
        UFixed6 a = UFixed6.wrap(21);
        UFixed6 b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(a / b), 2, "0.000021 / 0.000010 = 2");
    }

    function test_divisionZeroByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(UFixed6Lib.ZERO, UFixed6Lib.ZERO);
    }

    function test_divisionPositiveByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(UFixed6Lib.from(20), UFixed6Lib.ZERO);
    }

    function test_divisionOutWithoutRounding() public view {
        UFixed6 a = UFixed6.wrap(20);
        UFixed6 b = UFixed6.wrap(10);
        assertEq(UFixed6.unwrap(m.divOut(a, b)), 2e6, "20 / 10 = 2");
    }

    function test_divisionRoundsAwayFromZero() public view {
        UFixed6 a = UFixed6.wrap(21);
        UFixed6 b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(m.divOut(a, b)), 3, "0.000021 / 10 = 0.000003");
    }

    function test_divisionOutZeroByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(UFixed6Lib.ZERO, UFixed6Lib.ZERO);
    }

    function test_divisionOutPositiveByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(UFixed6Lib.from(20), UFixed6Lib.ZERO);
    }

    function test_unsafeDivision() public view {
        UFixed6 a = UFixed6Lib.from(20);
        UFixed6 b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(m.unsafeDiv(a, b)), 2e6, "20 / 10 = 2");

        a = UFixed6.wrap(21);
        b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(m.unsafeDiv(a, b)), 2, "divides and floors");

        assertEq(UFixed6.unwrap(m.unsafeDiv(UFixed6Lib.ZERO, UFixed6Lib.ZERO)), 1e6, "0 / 0 = 1");
        a = UFixed6Lib.from(20);
        assertEq(UFixed6.unwrap(m.unsafeDiv(a, UFixed6Lib.ZERO)), type(uint256).max, "20 / 0 = MaxInt");
    }

    function test_unsafeDivisionOut() public view {
        UFixed6 a = UFixed6Lib.from(20);
        UFixed6 b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(m.unsafeDivOut(a, b)), 2e6, "20 / 10 = 2");

        a = UFixed6.wrap(21);
        b = UFixed6Lib.from(10);
        assertEq(UFixed6.unwrap(m.unsafeDivOut(a, b)), 3, "divides and ceils");

        assertEq(UFixed6.unwrap(m.unsafeDivOut(UFixed6Lib.ZERO, UFixed6Lib.ZERO)), 1e6, "0 / 0 = 1");
        a = UFixed6Lib.from(20);
        assertEq(UFixed6.unwrap(m.unsafeDivOut(a, UFixed6Lib.ZERO)), type(uint256).max, "20 / 0 = MaxUInt");
    }

    function test_mulDiv() public pure {
        UFixed6 a = UFixed6Lib.from(20);
        assertEq(UFixed6.unwrap(a.muldiv(10e6, 2e6)), 100e6, "muldiv(Fixed6, uint256, uint256)");

        UFixed6 b = UFixed6Lib.from(10);
        UFixed6 c = UFixed6Lib.from(2);
        assertEq(UFixed6.unwrap(a.muldivFixed(b, c)), 100e6, "muldiv(uf6, uf6, uf6)");

        a = UFixed6.wrap(1_111111);
        b = UFixed6.wrap(3_333333);
        assertEq(UFixed6.unwrap(a.muldivFixed(b, b)), 1_111111, "muldiv(uf6, uf6, uf6) precision");
    }

    function test_mulDivRoundsTowardsZero() public pure {
        UFixed6 a = UFixed6.wrap(1);
        assertEq(UFixed6.unwrap(a.muldiv(21, 10)), 2, "muldiv(uf6, i, i) 1*21/10 = 2");

        a = UFixed6.wrap(1);
        UFixed6 b = UFixed6.wrap(21);
        UFixed6 c = UFixed6.wrap(10);
        assertEq(UFixed6.unwrap(a.muldivFixed(b, c)), 2, "muldiv(uf6, uf6, uf6) 1*21/10 = 2");
    }

    function test_mulDivSignedRevertsIfDivisorIsZero() public {
        UFixed6 a = UFixed6Lib.from(20);
        vm.expectRevert(stdError.divisionError);
        m.mulDiv(a, 10e6, 0);
    }

    function test_mulDivFixedRevertsIfDivisorIsZero() public {
        UFixed6 a = UFixed6Lib.from(20);
        UFixed6 b = UFixed6Lib.from(10);
        UFixed6 c = UFixed6Lib.ZERO;
        vm.expectRevert(stdError.divisionError);
        m.muldivFixed(a, b, c);
    }

    function test_mulDivOutFixed() public pure {
        UFixed6 a = UFixed6Lib.from(20);
        assertEq(UFixed6.unwrap(a.muldivOut(10e6, 2e6)), 100e6, "muldivOut(uf6, uint256, uint256)");

        UFixed6 b = UFixed6Lib.from(10);
        UFixed6 c = UFixed6Lib.from(2);
        assertEq(UFixed6.unwrap(a.muldivOutFixed(b, c)), 100e6, "muldivOut(uf6, uf6, uf6)");

        a = UFixed6.wrap(1_111111);
        uint256 bi = 333333;
        assertEq(UFixed6.unwrap(a.muldivOut(bi, bi)), 1_111111, "muldivOut(uf6, uint256, uint256) precision");

        b = UFixed6.wrap(333333);
        assertEq(UFixed6.unwrap(a.muldivOutFixed(b, b)), 1_111111, "muldivOut(uf6, uf6, uf6) precision");
    }

    function test_mulDivOutRoundsAwayFromZero() public pure {
        UFixed6 a = UFixed6.wrap(1);
        assertEq(UFixed6.unwrap(a.muldivOut(21, 10)), 3, "muldivOut(uf6, uint256, uint256) 1*21/10 = 3");

        a = UFixed6.wrap(1);
        UFixed6 b = UFixed6.wrap(21);
        UFixed6 c = UFixed6.wrap(10);
        assertEq(UFixed6.unwrap(a.muldivOutFixed(b, c)), 3, "muldivOut(uf6, uf6, uf6) 1*21/10 = 3");
    }

    function test_mulDivOutFixedRevertsIfDivisorIsZero() public {
        UFixed6 a = UFixed6Lib.from(20);
        UFixed6 b = UFixed6Lib.from(10);
        UFixed6 c = UFixed6Lib.ZERO;
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.muldivOutFixed(a, b, c);
    }

    function test_equals() public pure {
        UFixed6 a = UFixed6.wrap(12);
        UFixed6 b = UFixed6.wrap(12);
        assertEq(a == b, true, "12 == 12");
        a = UFixed6.wrap(11);
        b = UFixed6.wrap(12);
        assertEq(a == b, false, "11 != 12");
    }

    function test_notEquals() public pure {
        UFixed6 a = UFixed6.wrap(12);
        UFixed6 b = UFixed6.wrap(12);
        assertEq(a != b, false, "12 != 12");
        a = UFixed6.wrap(11);
        b = UFixed6.wrap(12);
        assertEq(a != b, true, "11 == 12");
    }

    function test_greaterThan() public pure {
        UFixed6 a = UFixed6.wrap(13);
        UFixed6 b = UFixed6.wrap(12);
        assertEq(a > b, true, "13 > 12");
        a = UFixed6.wrap(12);
        b = UFixed6.wrap(12);
        assertEq(a > b, false, "12 !> 12");
        a = UFixed6.wrap(11);
        assertEq(a > b, false, "11 !> 12");
    }

    function test_lessThan() public pure {
        UFixed6 a = UFixed6.wrap(13);
        UFixed6 b = UFixed6.wrap(12);
        assertEq(a < b, false, "13 !< 12");
        a = UFixed6.wrap(12);
        assertEq(a < b, false, "12 !< 12");
        a = UFixed6.wrap(11);
        b = UFixed6.wrap(12);
        assertEq(a < b, true, "11 < 12");
    }

    function test_greaterThanOrEqualTo() public pure {
        UFixed6 a = UFixed6.wrap(13);
        UFixed6 b = UFixed6.wrap(12);
        assertEq(a >= b, true, "13 >= 12");
        a = UFixed6.wrap(12);
        b = UFixed6.wrap(12);
        assertEq(a >= b, true, "12 >= 12");
        a = UFixed6.wrap(11);
        b = UFixed6.wrap(12);
        assertEq(a >= b, false, "11 !>= 12");
    }

    function test_lessThanOrEqualTo() public pure {
        UFixed6 a = UFixed6.wrap(13);
        UFixed6 b = UFixed6.wrap(12);
        assertEq(a <= b, false, "13 !<= 12");
        a = UFixed6.wrap(12);
        assertEq(a <= b, true, "12 <= 12");
        a = UFixed6.wrap(11);
        b = UFixed6.wrap(12);
        assertEq(a <= b, true, "11 <= 12");
    }

    function test_compare() public pure {
        UFixed6 a = UFixed6.wrap(13);
        UFixed6 b = UFixed6.wrap(12);
        assertEq(a.compare(b), 2, "compare positive");
        a = UFixed6.wrap(12);
        b = UFixed6.wrap(12);
        assertEq(a.compare(b), 1, "compare zero");
        a = UFixed6.wrap(11);
        b = UFixed6.wrap(12);
        assertEq(a.compare(b), 0, "compare negative");
    }

    function test_ratio() public pure {
        assertEq(UFixed6.unwrap(UFixed6Lib.ratio(2000, 100)), 20e6, "2000/100 = 20");
    }

    function test_min() public pure {
        UFixed6 a = UFixed6.wrap(2000);
        UFixed6 b = UFixed6.wrap(100);
        assertEq(UFixed6.unwrap(a.min(b)), 100, "min(2000, 100) = 100");
        a = UFixed6.wrap(100);
        b = UFixed6.wrap(2000);
        assertEq(UFixed6.unwrap(a.min(b)), 100, "min(100, 2000) = 100");
    }

    function test_max() public pure {
        UFixed6 a = UFixed6.wrap(2000);
        UFixed6 b = UFixed6.wrap(100);
        assertEq(UFixed6.unwrap(a.max(b)), 2000, "max(2000, 100) = 2000");
        a = UFixed6.wrap(100);
        b = UFixed6.wrap(2000);
        assertEq(UFixed6.unwrap(a.max(b)), 2000, "max(100, 2000) = 2000");
    }

    function test_truncate() public pure {
        UFixed6 a = UFixed6.wrap(123_456000);
        assertEq(a.truncate(), 123, "truncate returns floor");
    }

    function test_inside() public pure {
        UFixed6 a = UFixed6.wrap(12);
        UFixed6 b = UFixed6.wrap(10);
        UFixed6 c = UFixed6.wrap(15);
        assertEq(a.inside(b, c), true, "inside");
        a = UFixed6.wrap(10);
        assertEq(a.inside(b, c), true, "on lower bound");
        a = UFixed6.wrap(15);
        assertEq(a.inside(b, c), true, "on upper bound");
        a = UFixed6.wrap(9);
        assertEq(a.inside(b, c), false, "below lower bound");
        a = UFixed6.wrap(16);
        assertEq(a.inside(b, c), false, "above upper bound");
    }

    function test_outside() public pure {
        UFixed6 a = UFixed6.wrap(12);
        UFixed6 b = UFixed6.wrap(10);
        UFixed6 c = UFixed6.wrap(15);
        assertEq(a.outside(b, c), false, "inside");
        a = UFixed6.wrap(10);
        assertEq(a.outside(b, c), false, "on lower bound");
        a = UFixed6.wrap(15);
        assertEq(a.outside(b, c), false, "on upper bound");
        a = UFixed6.wrap(9);
        assertEq(a.outside(b, c), true, "below lower bound");
        a = UFixed6.wrap(16);
        assertEq(a.outside(b, c), true, "above upper bound");
    }

    function test_exp() public pure {
        assertEq(UFixed6.unwrap(UFixed6Lib.exp(UFixed6Lib.from(0))), 1e6, "exp(0) = 1");

        assertEq(UFixed6.unwrap(UFixed6Lib.exp(UFixed6Lib.from(1))), 2_718281, "exp(1) = 2.718281");
        assertEq(UFixed6.unwrap(UFixed6Lib.exp(UFixed6Lib.from(2))), 7_389056, "exp(2) = 7.389056");
        assertEq(UFixed6.unwrap(UFixed6Lib.exp(UFixed6Lib.from(10))), 22026_465794, "exp(10) = 22026.465794");
        assertEq(UFixed6.unwrap(UFixed6Lib.exp(UFixed6.wrap(0.5e6))), 1_648721, "exp(0.5) = 1.648721");
        assertEq(UFixed6.unwrap(UFixed6Lib.exp(UFixed6.wrap(5))), 1_000005, "exp(0.000005) = 1.000005");
    }
}

contract MockUFixed6 {
    function from(Fixed6 a) external pure returns (UFixed6) {
        return UFixed6Lib.from(a);
    }

    function fromSignificandAndExponent(UFixed6 significand, int256 exponent) external pure returns (UFixed6) {
        return UFixed6Lib.from(significand, exponent);
    }

    function sub(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return a - b;
    }

    function div(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return a / b;
    }

    function divOut(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return a.divOut(b);
    }

    function unsafeDiv(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return a.unsafeDiv(b);
    }

    function unsafeDivOut(UFixed6 a, UFixed6 b) external pure returns (UFixed6) {
        return a.unsafeDivOut(b);
    }

    function mulDiv(UFixed6 a, uint256 b, uint256 c) external pure returns (UFixed6) {
        return a.muldiv(b, c);
    }

    function muldivFixed(UFixed6 a, UFixed6 b, UFixed6 c) external pure returns (UFixed6) {
        return a.muldivFixed(b, c);
    }

    function muldivOut(UFixed6 a, uint256 b, uint256 c) external pure returns (UFixed6) {
        return a.muldivOut(b, c);
    }

    function muldivOutFixed(UFixed6 a, UFixed6 b, UFixed6 c) external pure returns (UFixed6) {
        return a.muldivOutFixed(b, c);
    }
}
