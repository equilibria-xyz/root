// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/JumpRateUtilizationCurve6.sol";

contract MockJumpRateUtilizationCurve6 {
    function compute(JumpRateUtilizationCurve6 memory self, UFixed6 utilization) external pure returns (Fixed6) {
        return JumpRateUtilizationCurve6Lib.compute(self, utilization);
    }
}
