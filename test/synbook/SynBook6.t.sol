// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { RootTest } from "../RootTest.sol";

import { SynBook6 } from "../../src/synbook/types/SynBook6.sol";
import { Fixed6, Fixed6Lib } from "../../src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";

contract SynBook6Test is RootTest {
    SynBook6 curve1 = SynBook6({
        d0: UFixed6.wrap(2000), // 0.002
        d1: UFixed6Lib.ZERO,
        d2: UFixed6.wrap(1000), // 0.001
        d3: UFixed6.wrap(10000), // 0.01
        scale: UFixed6Lib.from(1000)
    });

    SynBook6 curve2 = SynBook6({
        d0: UFixed6.wrap(2000), // 0.002
        d1: UFixed6.wrap(4000), // 0.004
        d2: UFixed6.wrap(1000), // 0.001
        d3: UFixed6.wrap(10000), // 0.01
        scale: UFixed6Lib.from(1000)
    });

    UFixed6 price;

    function setUp() public {
        price = UFixed6Lib.from(123);
    }

    function test_computeCurve1ZeroSkew() public view {
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.ZERO, price),
            Fixed6Lib.ZERO,
            "zero skew, zero change"
        );
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.from(100), price),
            Fixed6.wrap(2467175), // 2.467175
            "zero skew, positive change"
        );
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.from(-100), price),
            Fixed6.wrap(2467175), // 2.467175
            "zero skew, negative change"
        );
    }

    function test_computeCurve1PositiveSkew() public view {
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.from(200), Fixed6Lib.ZERO, price),
            Fixed6Lib.ZERO,
            "positive skew, zero change"
        );
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.from(200), Fixed6Lib.from(100), price),
            Fixed6.wrap(2737775), // 2.737775
            "positive skew, positive change"
        );
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.from(200), Fixed6Lib.from(-100), price),
            Fixed6.wrap(2442575), // 2.442575
            "positive skew, negative change"
        );
    }

    function test_computeCurve1NegativeSkew() public view {
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.from(-200), Fixed6Lib.ZERO, price),
            Fixed6Lib.ZERO,
            "negative skew, zero change"
        );
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.from(-200), Fixed6Lib.from(100), price),
            Fixed6.wrap(2442575), // 2.442575
            "negative skew, positive change"
        );
        assertFixed6Eq(
            curve1.compute(Fixed6Lib.from(-200), Fixed6Lib.from(-100), price),
            Fixed6.wrap(2737775), // 2.737775
            "negative skew, negative change"
        );
    }

    function test_computeCurve2ZeroSkew() public view {
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.ZERO, Fixed6Lib.ZERO, price),
            Fixed6Lib.ZERO,
            "zero skew, zero change"
        );
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.ZERO, Fixed6Lib.from(100), price),
            Fixed6.wrap(2713175), // 2.713175
            "zero skew, positive change"
        );
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.ZERO, Fixed6Lib.from(-100), price),
            Fixed6.wrap(2713175), // 2.713175
            "zero skew, negative change"
        );
    }

    function test_computeCurve2PositiveSkew() public view {
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.from(200), Fixed6Lib.ZERO, price),
            Fixed6Lib.ZERO,
            "positive skew, zero change"
        );
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.from(200), Fixed6Lib.from(100), price),
            Fixed6.wrap(3967775), // 3.967775
            "positive skew, positive change"
        );
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.from(200), Fixed6Lib.from(-100), price),
            Fixed6.wrap(1704575), // 1.704575
            "positive skew, negative change"
        );
    }

    function test_computeCurve2NegativeSkew() public view {
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.from(-200), Fixed6Lib.ZERO, price),
            Fixed6Lib.ZERO,
            "negative skew, zero change"
        );
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.from(-200), Fixed6Lib.from(100), price),
            Fixed6.wrap(1704575), // 1.704575
            "negative skew, positive change"
        );
        assertFixed6Eq(
            curve2.compute(Fixed6Lib.from(-200), Fixed6Lib.from(-100), price),
            Fixed6.wrap(3967775), // 3.967775
            "negative skew, negative change"
        );
    }
}