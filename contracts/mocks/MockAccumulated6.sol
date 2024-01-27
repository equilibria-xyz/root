// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../accumulator/types/Accumulated6.sol";

contract MockAccumulated6 {
    function accumulated(
        Accumulated6 memory self,
        Accumulated6 memory from,
        UFixed6 total
    ) external pure returns (Fixed6) {
        return self.accumulated(from, total);
    }

    function increment(
        Accumulated6 memory self,
        Fixed6 amount,
        UFixed6 total
    ) external pure returns (Accumulated6 memory) {
        self.increment(amount, total);
        return self;
    }

    function decrement(
        Accumulated6 memory self,
        Fixed6 amount,
        UFixed6 total
    ) external pure returns (Accumulated6 memory) {
        self.decrement(amount, total);
        return self;
    }
}
