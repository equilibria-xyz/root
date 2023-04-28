// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/JumpRateUtilizationCurve18.sol";

contract MockJumpRateUtilizationCurve18 {
    function compute(JumpRateUtilizationCurve18 memory self, UFixed18 utilization) external pure returns (Fixed18) {
        return JumpRateUtilizationCurve18Lib.compute(self, utilization);
    }

    function read(JumpRateUtilizationCurve18Storage slot) external view returns (JumpRateUtilizationCurve18 memory) {
        return slot.read();
    }

    function store(JumpRateUtilizationCurve18Storage slot, JumpRateUtilizationCurve18 memory value) external {
        slot.store(value);
    }
}
