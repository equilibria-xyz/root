// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/JumpRateUtilizationCurve6.sol";

contract MockJumpRateUtilizationCurve6 {
    function compute(JumpRateUtilizationCurve6 memory self, UFixed6 utilization) external pure returns (Fixed6) {
        return JumpRateUtilizationCurve6Lib.compute(self, utilization);
    }

    function read(JumpRateUtilizationCurve6Storage slot) external view returns (JumpRateUtilizationCurve6 memory) {
        return slot.read();
    }

    function store(JumpRateUtilizationCurve6Storage slot, JumpRateUtilizationCurve6 memory value) external {
        slot.store(value);
    }
}
