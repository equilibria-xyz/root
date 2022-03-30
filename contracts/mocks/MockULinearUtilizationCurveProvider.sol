// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/unstructured/ULinearUtilizationCurveProvider.sol";

contract MockULinearUtilizationCurveProvider is ULinearUtilizationCurveProvider {
    function __initialize(LinearUtilizationCurve memory initialUtilizationCurve) external initializer {
        super.__UOwnable__initialize();
        super.__ULinearUtilizationCurveProvider__initialize(initialUtilizationCurve);
    }

    function computeUtilizationCurve(UFixed18 utilization) external view returns (Fixed18) {
        return super._computeUtilizationCurve(utilization);
    }
}
