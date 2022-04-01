// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../curve/immutable/XLinearUtilizationCurveProvider.sol";

contract MockXLinearUtilizationCurveProvider is XLinearUtilizationCurveProvider {
    constructor(LinearUtilizationCurve memory initialUtilizationCurve)
    XLinearUtilizationCurveProvider(initialUtilizationCurve)
    { }

    function computeRate(UFixed18 utilization) external view returns (Fixed18) {
        return super._computeRate(utilization);
    }
}
