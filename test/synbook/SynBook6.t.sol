// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { SynBook6 } from "../../src/synbook/types/SynBook6.sol";
import { Fixed6, Fixed6Lib } from "../../src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";
import { RootTest } from "../RootTest.sol";

contract SynBook6Test is RootTest {
    SynBook6 curve1 = SynBook6({
        d0: UFixed6.wrap(2000), // 0.002
        d1: UFixed6Lib.ZERO,
        d2: UFixed6.wrap(1000), // 0.001
        d3: UFixed6.wrap(10000), // 0.01
        limit: UFixed6Lib.from(1000)
    });

    SynBook6 curve2 = SynBook6({
        d0: UFixed6.wrap(2000), // 0.002
        d1: UFixed6.wrap(4000), // 0.004
        d2: UFixed6.wrap(1000), // 0.001
        d3: UFixed6.wrap(10000), // 0.01
        limit: UFixed6Lib.from(1000)
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
            price - UFixed6.wrap(24671), // price - 0.024671
            "zero skew, negative change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.ZERO, Fixed6Lib.from(-100), price),
            price + UFixed6.wrap(24671), // price + 0.024671
            "zero skew, positive change"
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
            price - UFixed6.wrap(27377), // price - 0.027377
            "positive skew, negative change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(200), Fixed6Lib.from(-100), price),
            price + UFixed6.wrap(24425), // price + 0.024425
            "positive skew, positive change"
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
            price - UFixed6.wrap(24425), // price + 0.024425
            "negative skew, negative change"
        );
        assertUFixed6Eq(
            curve1.compute(Fixed6Lib.from(-200), Fixed6Lib.from(-100), price),
            price + UFixed6.wrap(27377), // price + 0.027377
            "negative skew, positive change"
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
            price - UFixed6.wrap(27131), // price - 0.027131
            "zero skew, negative change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.ZERO, Fixed6Lib.from(-100), price),
            price + UFixed6.wrap(27131), // price + 0.027131
            "zero skew, positive change"
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
            price - UFixed6.wrap(39677), // price - 0.039677
            "positive skew, negative change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(200), Fixed6Lib.from(-100), price),
            price + UFixed6.wrap(17045), // price + 0.017045
            "positive skew, positive change"
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
            price - UFixed6.wrap(17045), // price - 0.017045
            "negative skew, negative change"
        );
        assertUFixed6Eq(
            curve2.compute(Fixed6Lib.from(-200), Fixed6Lib.from(-100), price),
            price + UFixed6.wrap(39677), // price + 0.039677
            "negative skew, positive change"
        );
    }
}