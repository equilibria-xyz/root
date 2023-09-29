// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../pid/types/PController6.sol";

contract MockPController6 {
    function compute(
        PController6 memory self,
        Fixed6 value,
        Fixed6 skew,
        uint256 fromTimestamp,
        uint256 toTimestamp
    ) external pure returns (Fixed6 newValue, UFixed6 interceptTimestamp) {
        return PController6Lib.compute(self, value, skew, fromTimestamp, toTimestamp);
    }
}
