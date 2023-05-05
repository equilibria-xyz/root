// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/JumpRateUtilizationCurve.sol";

contract MockJumpRateUtilizationCurve {
    function compute(JumpRateUtilizationCurve memory self, UFixed18 utilization) external pure returns (Fixed18) {
        return JumpRateUtilizationCurveLib.compute(self, utilization);
    }

    function read(JumpRateUtilizationCurveStorage slot) external view returns (JumpRateUtilizationCurve memory) {
        return slot.read();
    }

    function store(JumpRateUtilizationCurveStorage slot, JumpRateUtilizationCurve memory value) external {
        slot.store(value);
    }
}
