// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { Test } from "forge-std/Test.sol";

import { UFixed18, UFixed18Lib, UFixed18Storage, UFixed18StorageLib } from "../../src/number/types/UFixed18.sol";
import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";
import { Fixed18, Fixed18Lib } from "../../src/number/types/Fixed18.sol";
import { NumberMath } from "../../src/number/NumberMath.sol";

contract UFixed18Test is Test {
    MockUFixed18 m = new MockUFixed18();

    function test_constants() public pure {
        assertEq(UFixed18.unwrap(UFixed18Lib.ZERO), 0);
        assertEq(UFixed18.unwrap(UFixed18Lib.ONE), 1e18);
        assertEq(UFixed18.unwrap(UFixed18Lib.MAX), type(uint256).max);
    }

    function test_from() public pure {
        UFixed18 f18 = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(f18), 10e18);
    }

    function test_fromFixed6() public pure {
        Fixed18 ten_f18 = Fixed18Lib.from(10);
        assertEq(UFixed18.unwrap(UFixed18Lib.from(ten_f18)), 10e18);
    }

    function test_unsafeFromFixed18() public pure {
        Fixed18 a = Fixed18.wrap(-1);
        assertEq(UFixed18.unwrap(UFixed18Lib.unsafeFrom(a)), 0);

        Fixed18 b = Fixed18.wrap(1);
        assertEq(UFixed18.unwrap(UFixed18Lib.unsafeFrom(b)), 1);
    }

    function test_fromFixed18RevertsIfLessThanZero() public {
        Fixed18 a = Fixed18.wrap(-1);
        vm.expectRevert(abi.encodeWithSelector(UFixed18Lib.UFixed18UnderflowError.selector, -1));
        m.from(a);
    }

    function test_fromUFixed6() public pure {
        UFixed6 ten_u6 = UFixed6Lib.from(10);
        assertEq(UFixed18.unwrap(UFixed18Lib.from(ten_u6)), 10e18);
    }

    function test_fromSignificantAndExponent() public pure {
        UFixed18 ten_pow_2 = UFixed18Lib.from(UFixed18Lib.from(10), 2);
        assertEq(UFixed18.unwrap(ten_pow_2), 10e20, "10^2");

        UFixed18 ten_pow_neg2 = UFixed18Lib.from(UFixed18Lib.from(10), -2);
        assertEq(UFixed18.unwrap(ten_pow_neg2), 10e16, "10^-2");

        assertEq(UFixed18.unwrap(UFixed18Lib.from(UFixed18Lib.ZERO, 6)), 0, "0^6");
        assertEq(UFixed18.unwrap(UFixed18Lib.from(UFixed18Lib.ZERO, 0)), 0, "0^0");

        UFixed18 ten_pow_0 = UFixed18Lib.from(UFixed18Lib.from(10), 0);
        assertEq(UFixed18.unwrap(ten_pow_0), 10e18, "10^0");

        UFixed18 LARGE_SIGNIFICAND = UFixed18.wrap(1e40);
        assertEq(UFixed18.unwrap(UFixed18Lib.from(LARGE_SIGNIFICAND, 1)), 1e41);
        assertEq(UFixed18.unwrap(UFixed18Lib.from(LARGE_SIGNIFICAND, -1)), 1e39);
    }

    function test_fromSignificantAndExponentRevertsIfTooLarge() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(UFixed18Lib.ONE, type(int256).max);
    }

    function test_fromSignificantAndExponentRevertsIfTooSmall() public {
        vm.expectRevert(stdError.arithmeticError);
        m.fromSignificandAndExponent(UFixed18Lib.ONE, type(int256).min + 1);
    }

    function test_isZero() public pure {
        assertEq(UFixed18Lib.isZero(UFixed18Lib.ZERO), true, "0 is zero");
        assertEq(UFixed18Lib.isZero(UFixed18Lib.ONE), false, "1 is not zero");
    }

    function test_addition() public pure {
        UFixed18 a = UFixed18Lib.from(10);
        UFixed18 b = UFixed18Lib.from(20);
        assertEq(UFixed18.unwrap(a.add(b)), 30e18, "10.add(20) = 30");
        assertEq(UFixed18.unwrap(a + b), 30e18, "10 + 20 = 30");
    }

    function test_subtraction() public pure {
        UFixed18 a = UFixed18Lib.from(20);
        UFixed18 b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(a.sub(b)), 10e18, "20.sub(10) = 10");
        assertEq(UFixed18.unwrap(a - b), 10e18, "20 - 10 = 10");
    }

    function test_subtractionRevertsIfNegative() public {
        UFixed18 a = UFixed18Lib.from(10);
        UFixed18 b = UFixed18Lib.from(20);
        vm.expectRevert(stdError.arithmeticError);
        m.sub(a, b);
    }

    function test_unsafeSubtraction() public pure {
        UFixed18 a = UFixed18Lib.from(10);
        UFixed18 b = UFixed18Lib.from(20);
        assertEq(UFixed18.unwrap(UFixed18Lib.unsafeSub(a, b)), 0);

        a = UFixed18Lib.from(30);
        assertEq(UFixed18.unwrap(UFixed18Lib.unsafeSub(a, b)), 10e18);
    }

    function test_multiplication() public pure {
        UFixed18 a = UFixed18Lib.from(20);
        UFixed18 b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(a.mul(b)), 200e18, "20 * 10 = 200");
    }

    function test_MultiplicationRoundsTowardZero() public pure {
        UFixed18 a = UFixed18.wrap(1);
        UFixed18 b = UFixed18.wrap(2);
        assertEq(UFixed18.unwrap(a * b), 0, "0.000000000_000000001 * 0.000000000_000000002 = 0");
    }

    function test_multiplicationOut() public pure {
        UFixed18 a = UFixed18Lib.from(20);
        UFixed18 b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(UFixed18Lib.mulOut(a, b)), 200e18, "20 * 10 = 200");
    }

    function test_multiplicationOutRoundsAwayFromZero() public pure {
        UFixed18 a = UFixed18.wrap(1);
        UFixed18 b = UFixed18.wrap(2);
        assertEq(UFixed18.unwrap(UFixed18Lib.mulOut(a, b)), 1, "0.000000000_000000001 * 0.000000000_000000002 = 0.000000000_000000001");
    }

    function test_division() public pure {
        UFixed18 a = UFixed18.wrap(20);
        UFixed18 b = UFixed18.wrap(10);
        assertEq(UFixed18.unwrap(a.div(b)), 2e18, "20 / 10 = 2");
    }

    function test_divisionRoundsTowardsZero() public pure {
        UFixed18 a = UFixed18.wrap(21);
        UFixed18 b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(a / b), 2, "0.000000000_000000021 / 0.000000000_000000010 = 2");
    }

    function test_divisionZeroByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(UFixed18Lib.ZERO, UFixed18Lib.ZERO);
    }

    function test_divisionPositiveByZero() public {
        vm.expectRevert(stdError.divisionError);
        m.div(UFixed18Lib.from(20), UFixed18Lib.ZERO);
    }

    function test_divisionOutWithoutRounding() public view {
        UFixed18 a = UFixed18.wrap(20);
        UFixed18 b = UFixed18.wrap(10);
        assertEq(UFixed18.unwrap(m.divOut(a, b)), 2e18, "20 / 10 = 2");
    }

    function test_divisionRoundsAwayFromZero() public view {
        UFixed18 a = UFixed18.wrap(21);
        UFixed18 b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(m.divOut(a, b)), 3, "0.000000000_000000021 / 0.000000000_000000010 = 0.000000000_000000003");
    }

    function test_divisionOutZeroByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(UFixed18Lib.ZERO, UFixed18Lib.ZERO);
    }

    function test_divisionOutPositiveByZero() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.divOut(UFixed18Lib.from(20), UFixed18Lib.ZERO);
    }

    function test_unsafeDivision() public view {
        UFixed18 a = UFixed18Lib.from(20);
        UFixed18 b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(m.unsafeDiv(a, b)), 2e18, "20 / 10 = 2");

        a = UFixed18.wrap(21);
        b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(m.unsafeDiv(a, b)), 2, "divides and floors");

        assertEq(UFixed18.unwrap(m.unsafeDiv(UFixed18Lib.ZERO, UFixed18Lib.ZERO)), 1e18, "0 / 0 = 1");
        a = UFixed18Lib.from(20);
        assertEq(UFixed18.unwrap(m.unsafeDiv(a, UFixed18Lib.ZERO)), type(uint256).max, "20 / 0 = MaxInt");
    }

    function test_unsafeDivisionOut() public view {
        UFixed18 a = UFixed18Lib.from(20);
        UFixed18 b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(m.unsafeDivOut(a, b)), 2e18, "20 / 10 = 2");

        a = UFixed18.wrap(21);
        b = UFixed18Lib.from(10);
        assertEq(UFixed18.unwrap(m.unsafeDivOut(a, b)), 3, "divides and ceils");

        assertEq(UFixed18.unwrap(m.unsafeDivOut(UFixed18Lib.ZERO, UFixed18Lib.ZERO)), 1e18, "0 / 0 = 1");
        a = UFixed18Lib.from(20);
        assertEq(UFixed18.unwrap(m.unsafeDivOut(a, UFixed18Lib.ZERO)), type(uint256).max, "20 / 0 = MaxUInt");
    }

    function test_mulDiv() public pure {
        UFixed18 a = UFixed18Lib.from(20);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldiv(a, 10e18, 2e18)), 100e18, "muldiv(uf18, uint256, uint256)");

        UFixed18 b = UFixed18Lib.from(10);
        UFixed18 c = UFixed18Lib.from(2);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldiv(a, b, c)), 100e18, "muldiv(uf18, uf18, uf18)");

        a = UFixed18.wrap(1_111111111_111111111);
        b = UFixed18.wrap(3_333333333_333333333);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldiv(a, b, b)), 1_111111111_111111111, "muldiv(uf18, uf18, uf18) precision");
    }

    function test_mulDivRoundsTowardsZero() public pure {
        UFixed18 a = UFixed18.wrap(1);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldiv(a, 21, 10)), 2, "muldiv(uf18, uint256, uint256) 1*21/10 = 2");

        a = UFixed18.wrap(1);
        UFixed18 b = UFixed18.wrap(21);
        UFixed18 c = UFixed18.wrap(10);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldiv(a, b, c)), 2, "muldiv(uf18, uf18, uf18) 1*21/10 = 2");
    }

    function test_mulDivSignedRevertsIfDivisorIsZero() public {
        UFixed18 a = UFixed18Lib.from(20);
        vm.expectRevert(stdError.divisionError);
        m.mulDiv(a, 10e18, 0);
    }

    function test_mulDivFixedRevertsIfDivisorIsZero() public {
        UFixed18 a = UFixed18Lib.from(20);
        UFixed18 b = UFixed18Lib.from(10);
        UFixed18 c = UFixed18Lib.ZERO;
        vm.expectRevert(stdError.divisionError);
        m.muldivFixed(a, b, c);
    }

    function test_mulDivOutFixed() public pure {
        UFixed18 a = UFixed18Lib.from(20);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldivOut(a, 10e18, 2e18)), 100e18, "muldivOut(uf18, uint256, uint256)");

        UFixed18 b = UFixed18Lib.from(10);
        UFixed18 c = UFixed18Lib.from(2);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldivOut(a, b, c)), 100e18, "muldivOut(uf18, uf18, uf18)");

        a = UFixed18.wrap(1_111111111_111111111);
        uint256 bi = 333333333_333333333;
        assertEq(UFixed18.unwrap(UFixed18Lib.muldivOut(a, bi, bi)), 1_111111111_111111111, "muldivOut(uf18, uint256, uint256) precision");

        b = UFixed18.wrap(333333333_333333333);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldivOut(a, b, b)), 1_111111111_111111111, "muldivOut(uf18, uf18, uf18) precision");
    }

    function test_mulDivOutRoundsAwayFromZero() public pure {
        UFixed18 a = UFixed18.wrap(1);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldivOut(a, 21, 10)), 3, "muldivOut(uf18, uint256, uint256) 1*21/10 = 3");

        a = UFixed18.wrap(1);
        UFixed18 b = UFixed18.wrap(21);
        UFixed18 c = UFixed18.wrap(10);
        assertEq(UFixed18.unwrap(UFixed18Lib.muldivOut(a, b, c)), 3, "muldivOut(uf18, uf18, uf18) 1*21/10 = 3");
    }

    function test_mulDivOutFixedRevertsIfDivisorIsZero() public {
        UFixed18 a = UFixed18Lib.from(20);
        UFixed18 b = UFixed18Lib.from(10);
        UFixed18 c = UFixed18Lib.ZERO;
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        m.muldivOutFixed(a, b, c);
    }

    function test_equals() public pure {
        UFixed18 a = UFixed18.wrap(12);
        UFixed18 b = UFixed18.wrap(12);
        assertEq(a.eq(b), true, "12 == 12");
        a = UFixed18.wrap(11);
        b = UFixed18.wrap(12);
        assertEq(a == b, false, "11 != 12");
    }

    function test_notEquals() public pure {
        UFixed18 a = UFixed18.wrap(12);
        UFixed18 b = UFixed18.wrap(12);
        assertEq(a.neq(b), false, "12 != 12");
        a = UFixed18.wrap(11);
        b = UFixed18.wrap(12);
        assertEq(a != b, true, "11 == 12");
    }

    function test_greaterThan() public pure {
        UFixed18 a = UFixed18.wrap(13);
        UFixed18 b = UFixed18.wrap(12);
        assertEq(a.gt(b), true, "13 > 12");
        a = UFixed18.wrap(12);
        b = UFixed18.wrap(12);
        assertEq(a > b, false, "12 !> 12");
        a = UFixed18.wrap(11);
        assertEq(a > b, false, "11 !> 12");
    }

    function test_lessThan() public pure {
        UFixed18 a = UFixed18.wrap(13);
        UFixed18 b = UFixed18.wrap(12);
        assertEq(a.lt(b), false, "13 !< 12");
        a = UFixed18.wrap(12);
        assertEq(a < b, false, "12 !< 12");
        a = UFixed18.wrap(11);
        b = UFixed18.wrap(12);
        assertEq(a < b, true, "11 < 12");
    }

    function test_greaterThanOrEqualTo() public pure {
        UFixed18 a = UFixed18.wrap(13);
        UFixed18 b = UFixed18.wrap(12);
        assertEq(a.gte(b), true, "13 >= 12");
        a = UFixed18.wrap(12);
        b = UFixed18.wrap(12);
        assertEq(a >= b, true, "12 >= 12");
        a = UFixed18.wrap(11);
        b = UFixed18.wrap(12);
        assertEq(a >= b, false, "11 !>= 12");
    }

    function test_lessThanOrEqualTo() public pure {
        UFixed18 a = UFixed18.wrap(13);
        UFixed18 b = UFixed18.wrap(12);
        assertEq(a.lte(b), false, "13 !<= 12");
        a = UFixed18.wrap(12);
        assertEq(a <= b, true, "12 <= 12");
        a = UFixed18.wrap(11);
        b = UFixed18.wrap(12);
        assertEq(a <= b, true, "11 <= 12");
    }

    function test_compare() public pure {
        UFixed18 a = UFixed18.wrap(13);
        UFixed18 b = UFixed18.wrap(12);
        assertEq(UFixed18Lib.compare(a, b), 2, "compare positive (positive arguments)");
        a = UFixed18.wrap(12);
        b = UFixed18.wrap(12);
        assertEq(UFixed18Lib.compare(a, b), 1, "compare zero");
        a = UFixed18.wrap(11);
        b = UFixed18.wrap(12);
        assertEq(UFixed18Lib.compare(a, b), 0, "compare negative (positive arguments)");
    }

    function test_ratio() public pure {
        assertEq(UFixed18.unwrap(UFixed18Lib.ratio(2000, 100)), 20e18, "2000/100 = 20");
    }

    function test_min() public pure {
        UFixed18 a = UFixed18.wrap(2000);
        UFixed18 b = UFixed18.wrap(100);
        assertEq(UFixed18.unwrap(UFixed18Lib.min(a, b)), 100, "min(2000, 100) = 100");
        a = UFixed18.wrap(100);
        b = UFixed18.wrap(2000);
        assertEq(UFixed18.unwrap(UFixed18Lib.min(a, b)), 100, "min(100, 2000) = 100");
    }

    function test_max() public pure {
        UFixed18 a = UFixed18.wrap(2000);
        UFixed18 b = UFixed18.wrap(100);
        assertEq(UFixed18.unwrap(UFixed18Lib.max(a, b)), 2000, "max(2000, 100) = 2000");
        a = UFixed18.wrap(100);
        b = UFixed18.wrap(2000);
        assertEq(UFixed18.unwrap(UFixed18Lib.max(a, b)), 2000, "max(100, 2000) = 2000");
    }

    function test_truncate() public pure {
        UFixed18 a = UFixed18.wrap(123_456000000_000000000);
        assertEq(UFixed18Lib.truncate(a), 123, "truncate returns floor");
    }

    function test_inside() public pure {
        UFixed18 a = UFixed18.wrap(12);
        UFixed18 b = UFixed18.wrap(10);
        UFixed18 c = UFixed18.wrap(15);
        assertEq(UFixed18Lib.inside(a, b, c), true, "inside");
        a = UFixed18.wrap(10);
        assertEq(UFixed18Lib.inside(a, b, c), true, "on lower bound");
        a = UFixed18.wrap(15);
        assertEq(UFixed18Lib.inside(a, b, c), true, "on upper bound");
        a = UFixed18.wrap(9);
        assertEq(UFixed18Lib.inside(a, b, c), false, "below lower bound");
        a = UFixed18.wrap(16);
        assertEq(UFixed18Lib.inside(a, b, c), false, "above upper bound");
    }

    function test_outside() public pure {
        UFixed18 a = UFixed18.wrap(12);
        UFixed18 b = UFixed18.wrap(10);
        UFixed18 c = UFixed18.wrap(15);
        assertEq(UFixed18Lib.outside(a, b, c), false, "inside");
        a = UFixed18.wrap(10);
        assertEq(UFixed18Lib.outside(a, b, c), false, "on lower bound");
        a = UFixed18.wrap(15);
        assertEq(UFixed18Lib.outside(a, b, c), false, "on upper bound");
        a = UFixed18.wrap(9);
        assertEq(UFixed18Lib.outside(a, b, c), true, "below lower bound");
        a = UFixed18.wrap(16);
        assertEq(UFixed18Lib.outside(a, b, c), true, "above upper bound");
    }

    function test_store() public {
        UFixed18Storage SLOT = UFixed18Storage.wrap(keccak256("equilibria.root.UFixed18.testSlot"));
        UFixed18StorageLib.store(SLOT, UFixed18.wrap(12));
        assertEq(UFixed18.unwrap(SLOT.read()), 12, "stored and loaded");
    }
}

contract MockUFixed18 {
    function from(Fixed18 a) external pure returns (UFixed18) {
        return UFixed18Lib.from(a);
    }

    function fromSignificandAndExponent(UFixed18 significand, int256 exponent) external pure returns (UFixed18) {
        return UFixed18Lib.from(significand, exponent);
    }

    function sub(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.sub(a, b);
    }

    function div(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.div(a, b);
    }

    function divOut(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.divOut(a, b);
    }

    function unsafeDiv(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.unsafeDiv(a, b);
    }

    function unsafeDivOut(UFixed18 a, UFixed18 b) external pure returns (UFixed18) {
        return UFixed18Lib.unsafeDivOut(a, b);
    }

    function mulDiv(UFixed18 a, uint256 b, uint256 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldiv(a, b, c);
    }

    function muldivFixed(UFixed18 a, UFixed18 b, UFixed18 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldiv(a, b, c);
    }

    function muldivOut(UFixed18 a, uint256 b, uint256 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldivOut(a, b, c);
    }

    function muldivOutFixed(UFixed18 a, UFixed18 b, UFixed18 c) external pure returns (UFixed18) {
        return UFixed18Lib.muldivOut(a, b, c);
    }
}
