// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../accumulator/types/AccumulatorValue6.sol";

contract MockAccumulatorValue6 {
    function accumulated(
        AccumulatorValue6 memory self,
        AccumulatorValue6 memory from,
        UFixed6 total
    ) external pure returns (Fixed6) {
        return self.accumulated(from, total);
    }

    function increment(
        AccumulatorValue6 memory self,
        Fixed6 amount,
        UFixed6 total
    ) external pure returns (AccumulatorValue6 memory) {
        self.increment(amount, total);
        return self;
    }

    function decrement(
        AccumulatorValue6 memory self,
        Fixed6 amount,
        UFixed6 total
    ) external pure returns (AccumulatorValue6 memory) {
        self.decrement(amount, total);
        return self;
    }
}
