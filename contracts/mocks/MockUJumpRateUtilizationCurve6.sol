// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/UJumpRateUtilizationCurve6.sol";

contract MockUJumpRateUtilizationCurve6 {
    function compute(UJumpRateUtilizationCurve6 memory self, UFixed6 utilization) external pure returns (UFixed6) {
        return UJumpRateUtilizationCurve6Lib.compute(self, utilization);
    }

    function read(UJumpRateUtilizationCurve6Storage slot) external view returns (UJumpRateUtilizationCurve6 memory) {
        return slot.read();
    }

    function store(UJumpRateUtilizationCurve6Storage slot, UJumpRateUtilizationCurve6 memory value) external {
        slot.store(value);
    }
}
