// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { RootTest } from "../RootTest.sol";

import { SynBook6 } from "../../src/synbook/types/SynBook6.sol";
import { Fixed6Lib } from "../../src/number/types/Fixed6.sol";
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
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.ZERO, price),
            price,
            "zero skew, zero change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.from(100), price),
            price.add(UFixed6.wrap(20058)), // price + (2.467175 / price)
            "zero skew, positive change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.from(-100), price),
            price.sub(UFixed6.wrap(20058)), // price - (2.467175 / price)
            "zero skew, negative change"
        );
    }

    function test_computeCurve1PositiveSkew() public view {
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(200), Fixed6Lib.ZERO, price),
            price,
            "positive skew, zero change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(200), Fixed6Lib.from(100), price),
            price.add(UFixed6.wrap(22258)), // price + (2.737775 / price)
            "positive skew, positive change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(200), Fixed6Lib.from(-100), price),
            price.sub(UFixed6.wrap(19858)), // price - (2.442575 / price)
            "positive skew, negative change"
        );
    }

    function test_computeCurve1NegativeSkew() public view {
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(-200), Fixed6Lib.ZERO, price),
            price,
            "negative skew, zero change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(-200), Fixed6Lib.from(100), price),
            price.add(UFixed6.wrap(19858)), // price + (2.442575 / price)
            "negative skew, positive change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(-200), Fixed6Lib.from(-100), price),
            price.sub(UFixed6.wrap(22258)), // price - (2.737775 / price)
            "negative skew, negative change"
        );
    }

    function test_computeCurve2ZeroSkew() public view {
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.ZERO, Fixed6Lib.ZERO, price),
            price,
            "zero skew, zero change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.ZERO, Fixed6Lib.from(100), price),
            price.add(UFixed6.wrap(22058)), // price + (2.713175 / price)
            "zero skew, positive change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.ZERO, Fixed6Lib.from(-100), price),
            price.sub(UFixed6.wrap(22058)), // price - (2.713175 / price)
            "zero skew, negative change"
        );
    }

    function test_computeCurve2PositiveSkew() public view {
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(200), Fixed6Lib.ZERO, price),
            price,
            "positive skew, zero change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(200), Fixed6Lib.from(100), price),
            price.add(UFixed6.wrap(32258)), // price + (3.967775 / price)
            "positive skew, positive change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(200), Fixed6Lib.from(-100), price),
            price.sub(UFixed6.wrap(13858)), // price - (1.704575 / price)
            "positive skew, negative change"
        );
    }

    function test_computeCurve2NegativeSkew() public view {
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(-200), Fixed6Lib.ZERO, price),
            price,
            "negative skew, zero change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(-200), Fixed6Lib.from(100), price),
            price.add(UFixed6.wrap(13858)), // price + (1.704575 / price)
            "negative skew, positive change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(-200), Fixed6Lib.from(-100), price),
            price.sub(UFixed6.wrap(32258)), // price - (3.967775 / price)
            "negative skew, negative change"
        );
    }
}