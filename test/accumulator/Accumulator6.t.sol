// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";
import { RootTest } from "../RootTest.sol";

import { Accumulator6 } from "../../src/accumulator/types/Accumulator6.sol";
import { Fixed6, Fixed6Lib } from "../../src/number/types/Fixed6.sol";
import { UFixed6, UFixed6Lib } from "../../src/number/types/UFixed6.sol";
import { NumberMath } from "../../src/number/NumberMath.sol";

contract Accumulator6Test is RootTest {
    MockAccumulator6 private acc;

    function setUp() public {
        acc = new MockAccumulator6();
    }

    function _value() private view returns (Fixed6) {
        return acc.value();
    }

    // increment

    function test_incrementsNoRounding() public {
        acc.increment(Fixed6Lib.from(2), UFixed6Lib.from(1));
        assertFixed6Eq(_value(), Fixed6Lib.from(2));

        acc.increment(Fixed6Lib.from(-3), UFixed6Lib.from(1));
        assertFixed6Eq(_value(), Fixed6Lib.from(-1));
    }

    function test_incrementsRoundingDown() public {
        acc.increment(Fixed6.wrap(1), UFixed6Lib.from(2));
        assertFixed6Eq(_value(), Fixed6Lib.ZERO);
    }

    function test_incrementsZeroAmountNonzeroTotal() public {
        acc.increment(Fixed6.wrap(0), UFixed6Lib.from(1));
        assertFixed6Eq(_value(), Fixed6Lib.ZERO);
    }

    function test_incrementsZeroAmountZeroTotal() public {
        acc.increment(Fixed6.wrap(0), UFixed6Lib.from(0));
        assertFixed6Eq(_value(), Fixed6Lib.ZERO);
    }

    function test_revertsIfIncrementNonzeroAmountZeroTotal() public {
        vm.expectRevert(stdError.divisionError);
        acc.increment(Fixed6.wrap(1), UFixed6Lib.ZERO);
    }

    // decrement

    function test_decrementsNoRounding() public {
        acc.decrement(Fixed6Lib.from(2), UFixed6Lib.from(1));
        assertFixed6Eq(_value(), Fixed6Lib.from(-2));

        acc.decrement(Fixed6Lib.from(-3), UFixed6Lib.from(1));
        assertFixed6Eq(_value(), Fixed6Lib.from(1));
    }

    function test_decrementsRoundingDown() public {
        acc.decrement(Fixed6.wrap(-1), UFixed6Lib.from(2));
        assertFixed6Eq(_value(), Fixed6Lib.ZERO);

        acc.decrement(Fixed6.wrap(1), UFixed6Lib.from(2));
        assertFixed6Eq(_value(), Fixed6.wrap(-1));
    }

    function test_decrementsZeroAmountNonzeroTotal() public {
        acc.decrement(Fixed6.wrap(0), UFixed6Lib.from(1));
        assertFixed6Eq(_value(), Fixed6Lib.ZERO);
    }

    function test_decrementsZeroAmountZeroTotal() public {
        acc.decrement(Fixed6.wrap(0), UFixed6Lib.from(0));
        assertFixed6Eq(_value(), Fixed6Lib.ZERO);
    }

    function test_revertsIfDecrementNonzeroAmountZeroTotal() public {
        vm.expectRevert(NumberMath.DivisionByZero.selector);
        acc.decrement(Fixed6.wrap(1), UFixed6Lib.ZERO);
    }

    // accumulated

    function test_returnsAccumulatedNoRounding() public {
        Accumulator6 memory from = acc.getAccumulator();
        acc.increment(Fixed6Lib.from(2), UFixed6Lib.from(5));
        assertFixed6Eq(acc.accumulated(from, UFixed6Lib.from(5)), Fixed6Lib.from(2));
    }

    function test_returnsPositiveAccumulatedRoundingDown() public {
        Accumulator6 memory from = acc.getAccumulator();
        acc.increment(Fixed6.wrap(1), UFixed6Lib.from(1));
        assertFixed6Eq(acc.accumulated(from, UFixed6.wrap(1)), Fixed6Lib.ZERO);
    }

    function test_returnsNegativeAccumulatedRoundingDown() public {
        Accumulator6 memory from = acc.getAccumulator();
        acc.decrement(Fixed6.wrap(1), UFixed6Lib.from(1));
        assertFixed6Eq(acc.accumulated(from, UFixed6.wrap(1_000001)), Fixed6.wrap(-2));
    }

    // reset

    function test_resets() public {
        acc.increment(Fixed6.wrap(2), UFixed6Lib.from(5));
        acc.reset();
        assertFixed6Eq(_value(), Fixed6Lib.ZERO);
    }
}

contract MockAccumulator6 {
    /// @dev Give tests an accumulator that they can mutate
    Accumulator6 private accumulator;

    function getAccumulator() external view returns (Accumulator6 memory) {
        return accumulator;
    }

    function value() external view returns (Fixed6) {
        return accumulator._value;
    }

    function accumulated(Accumulator6 memory from, UFixed6 total) external view returns (Fixed6) {
        return accumulator.accumulated(from, total);
    }

    function increment(Fixed6 amount, UFixed6 total) external {
        Accumulator6 memory self = accumulator;
        self.increment(amount, total);
        accumulator = self;
    }

    function decrement(Fixed6 amount, UFixed6 total) external {
        Accumulator6 memory self = accumulator;
        self.decrement(amount, total);
        accumulator = self;
    }

    function reset() external {
        Accumulator6 memory self = accumulator;
        self.reset();
        accumulator = self;
    }
}
