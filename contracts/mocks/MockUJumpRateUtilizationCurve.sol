// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/UJumpRateUtilizationCurve18.sol";

contract MockUJumpRateUtilizationCurve18 {
    function compute(UJumpRateUtilizationCurve18 memory self, UFixed18 utilization) external pure returns (UFixed18) {
        return UJumpRateUtilizationCurve18Lib.compute(self, utilization);
    }

    function read(UJumpRateUtilizationCurve18Storage slot) external view returns (UJumpRateUtilizationCurve18 memory) {
        return slot.read();
    }

    function store(UJumpRateUtilizationCurve18Storage slot, UJumpRateUtilizationCurve18 memory value) external {
        slot.store(value);
    }
}
