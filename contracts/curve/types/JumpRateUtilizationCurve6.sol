// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath6.sol";
import "../../number/types/Fixed6.sol";

/// @dev JumpRateUtilizationCurve6 type
struct JumpRateUtilizationCurve6 {
    Fixed6 minRate;
    Fixed6 maxRate;
    Fixed6 targetRate;
    UFixed6 targetUtilization;
}
using JumpRateUtilizationCurve6Lib for JumpRateUtilizationCurve6 global;
type JumpRateUtilizationCurve6Storage is bytes32;
using JumpRateUtilizationCurve6StorageLib for JumpRateUtilizationCurve6Storage global;

/**
 * @title JumpRateUtilizationCurve6Lib
 * @notice Library for the base-6 Jump Rate utilization curve type
 */
library JumpRateUtilizationCurve6Lib {
    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(JumpRateUtilizationCurve6 memory self, UFixed6 utilization) internal pure returns (Fixed6) {
        if (utilization.lt(self.targetUtilization)) {
            return CurveMath6.linearInterpolation(
                UFixed6Lib.ZERO,
                self.minRate,
                self.targetUtilization,
                self.targetRate,
                utilization
            );
        }
        if (utilization.lt(UFixed6Lib.ONE)) {
            return CurveMath6.linearInterpolation(
                self.targetUtilization,
                self.targetRate,
                UFixed6Lib.ONE,
                self.maxRate,
                utilization
            );
        }
        return self.maxRate;
    }

    function accumulate(
        JumpRateUtilizationCurve6 memory self,
        UFixed6 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) internal pure returns (Fixed6) {
        return compute(self, utilization)
            .mul(Fixed6Lib.from(int256(toTimestamp - fromTimestamp)))
            .mul(Fixed6Lib.from(notional))
            .div(Fixed6Lib.from(365 days));
    }
}

library JumpRateUtilizationCurve6StorageLib {
    function read(JumpRateUtilizationCurve6Storage self) internal view returns (JumpRateUtilizationCurve6 memory) {
        return _storagePointer(self);
    }

    function store(JumpRateUtilizationCurve6Storage self, JumpRateUtilizationCurve6 memory value) internal {
        JumpRateUtilizationCurve6 storage storagePointer = _storagePointer(self);

        storagePointer.minRate = value.minRate;
        storagePointer.maxRate = value.maxRate;
        storagePointer.targetRate = value.targetRate;
        storagePointer.targetUtilization = value.targetUtilization;
    }

    function _storagePointer(JumpRateUtilizationCurve6Storage self)
    private pure returns (JumpRateUtilizationCurve6 storage pointer) {
        assembly ("memory-safe") { pointer.slot := self }
    }
}
