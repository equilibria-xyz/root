// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../accumulator/types/Accumulator6.sol";

contract MockAccumulator6 {
    /// @dev Give tests an accumulator that they can mutate
    Accumulator6Storage private accumulatorStorage;

    function accumulator() external view returns (Accumulator6 memory) {
        return accumulatorStorage.read();
    }

    function accumulated(Accumulator6 memory from, UFixed6 total) external view returns (Fixed6) {
        return accumulatorStorage.read().accumulated(from, total);
    }

    function increment(Fixed6 amount, UFixed6 total) external {
        Accumulator6 memory self = accumulatorStorage.read();
        self.increment(amount, total);
        accumulatorStorage.store(self);
    }

    function decrement(Fixed6 amount, UFixed6 total) external {
        Accumulator6 memory self = accumulatorStorage.read();
        self.decrement(amount, total);
        accumulatorStorage.store(self);
    }
}
