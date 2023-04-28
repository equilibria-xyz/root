// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/types/LinearUtilizationCurve.sol";

contract MockLinearUtilizationCurve {
    function compute(LinearUtilizationCurve memory self, UFixed18 utilization) external pure returns (Fixed18) {
        return LinearUtilizationCurveLib.compute(self, utilization);
    }
}
