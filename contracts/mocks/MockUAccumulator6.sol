// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../accumulator/types/UAccumulator6.sol";

contract MockUAccumulator6 {
    /// @dev Give tests an accumulator that they can mutate
    UAccumulator6Storage private accumulatorStorage;

    function accumulator() external view returns (UAccumulator6 memory) {
        return accumulatorStorage.read();
    }

    function accumulated(UAccumulator6 memory from, UFixed6 total) external view returns (UFixed6) {
        return accumulatorStorage.read().accumulated(from, total);
    }

    function increment(UFixed6 amount, UFixed6 total) external {
        UAccumulator6 memory self = accumulatorStorage.read();
        self.increment(amount, total);
        accumulatorStorage.store(self);
    }
}
