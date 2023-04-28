// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/UJumpRateUtilizationCurve.sol";

contract MockUJumpRateUtilizationCurve {
    function compute(UJumpRateUtilizationCurve memory self, UFixed18 utilization) external pure returns (UFixed18) {
        return UJumpRateUtilizationCurveLib.compute(self, utilization);
    }

    function read(UJumpRateUtilizationCurveStorage slot) external view returns (UJumpRateUtilizationCurve memory) {
        return slot.read();
    }

    function store(UJumpRateUtilizationCurveStorage slot, UJumpRateUtilizationCurve memory value) external {
        slot.store(value);
    }
}
