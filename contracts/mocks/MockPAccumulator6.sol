// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../pid/types/PAccumulator6.sol";

contract MockPAccumulator6 {
    PAccumulator6 public accumulator;

    constructor(PAccumulator6 memory accumulator_) {
        accumulator = accumulator_;
    }

    function accumulate(
        PController6 memory controller,
        Fixed6 skew,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) external returns (Fixed6 accumulated) {
        PAccumulator6 memory self = accumulator;
        accumulated = self.accumulate(controller, skew, fromTimestamp, toTimestamp, notional);
        accumulator = self;
    }
}
