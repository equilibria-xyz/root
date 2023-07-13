// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../accumulator/types/PAccumulator6.sol";

contract MockPAccumulator6 {
    function accumulate(
        PAccumulator6 memory self,
        PController6 memory controller,
        Fixed6 skew,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) external pure returns (Fixed6 accumulated) {
        return PAccumulator6Lib.accumulate(self, controller, skew, fromTimestamp, toTimestamp, notional);
    }
}
