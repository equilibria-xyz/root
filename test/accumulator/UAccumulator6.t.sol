// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { stdError } from "forge-std/StdError.sol";

import { UAccumulator6 } from "src/accumulator/types/UAccumulator6.sol";
import { UFixed6, UFixed6Lib } from "src/number/types/UFixed6.sol";
import { NumberMath } from "src/number/NumberMath.sol";
import { RootTest } from "../RootTest.sol";

contract UAccumulator6Test is RootTest {
    MockUAccumulator6 private acc;

    function setUp() public {
        acc = new MockUAccumulator6();
    }

    function _value() private view returns (UFixed6) {
        return acc.value();
    }

    // increment

    function test_incrementsNoRounding() public {
        acc.increment(UFixed6Lib.from(2), UFixed6Lib.from(1));
        assertUFixed6Eq(_value(), UFixed6Lib.from(2));
    }

    function test_incrementsRoundingDown() public {
        acc.increment(UFixed6.wrap(1), UFixed6Lib.from(2));
        assertUFixed6Eq(_value(), UFixed6Lib.ZERO);
    }

    function test_incrementsZeroAmountNonzeroTotal() public {
        acc.increment(UFixed6.wrap(0), UFixed6Lib.from(1));
        assertUFixed6Eq(_value(), UFixed6Lib.ZERO);
    }

    function test_incrementsZeroAmountZeroTotal() public {
        acc.increment(UFixed6.wrap(0), UFixed6Lib.from(0));
        assertUFixed6Eq(_value(), UFixed6Lib.ZERO);
    }

    function test_revertsIfIncrementNonzeroAmountZeroTotal() public {
        vm.expectRevert(stdError.divisionError);
        acc.increment(UFixed6.wrap(1), UFixed6Lib.from(0));
    }

    // accumulated

    function test_returnsAccumulatedNoRounding() public {
        UAccumulator6 memory from = acc.getAccumulator();
        acc.increment(UFixed6Lib.from(2), UFixed6Lib.from(5));
        assertUFixed6Eq(acc.accumulated(from, UFixed6Lib.from(5)), UFixed6Lib.from(2));
    }

    function test_returnsAccumulatedRoundingDown() public {
        UAccumulator6 memory from = acc.getAccumulator();
        acc.increment(UFixed6.wrap(1), UFixed6Lib.from(1));
        assertUFixed6Eq(acc.accumulated(from, UFixed6Lib.ZERO), UFixed6Lib.ZERO);
    }

    // reset

    function test_resets() public {
        acc.increment(UFixed6Lib.from(2), UFixed6Lib.from(5));
        acc.reset();
        assertUFixed6Eq(_value(), UFixed6Lib.ZERO);
    }
}

contract MockUAccumulator6 {
    /// @dev Give tests an accumulator that they can mutate
    UAccumulator6 private accumulator;

    function getAccumulator() external view returns (UAccumulator6 memory) {
        return accumulator;
    }

    function value() external view returns (UFixed6) {
        return accumulator._value;
    }

    function accumulated(UAccumulator6 memory from, UFixed6 total) external view returns (UFixed6) {
        return accumulator.accumulated(from, total);
    }

    function increment(UFixed6 amount, UFixed6 total) external {
        UAccumulator6 memory self = accumulator;
        self.increment(amount, total);
        accumulator = self;
    }

    function reset() external {
        UAccumulator6 memory self = accumulator;
        self.reset();
        accumulator = self;
    }
}
