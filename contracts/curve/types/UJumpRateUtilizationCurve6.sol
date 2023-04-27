// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath6.sol";
import "../../number/types/UFixed6.sol";

/// @dev UJumpRateUtilizationCurve6 type
struct UJumpRateUtilizationCurve6 {
    UFixed6 minRate;
    UFixed6 maxRate;
    UFixed6 targetRate;
    UFixed6 targetUtilization;
}
using UJumpRateUtilizationCurve6Lib for UJumpRateUtilizationCurve6 global;
type UJumpRateUtilizationCurve6Storage is bytes32;
using UJumpRateUtilizationCurve6StorageLib for UJumpRateUtilizationCurve6Storage global;

/**
 * @title UJumpRateUtilizationCurve6Lib
 * @notice Library for the unsigned base-6 Jump Rate utilization curve type
 */
library UJumpRateUtilizationCurve6Lib {
    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(UJumpRateUtilizationCurve6 memory self, UFixed6 utilization) internal pure returns (UFixed6) {
        UFixed6 targetUtilization = self.targetUtilization;
        if (utilization.lt(targetUtilization)) {
            return CurveMath6.linearInterpolation(
                UFixed6Lib.ZERO,
                self.minRate,
                targetUtilization,
                self.targetRate,
                utilization
            );
        }
        if (utilization.lt(UFixed6Lib.ONE)) {
            return CurveMath6.linearInterpolation(
                targetUtilization,
                self.targetRate,
                UFixed6Lib.ONE,
                self.maxRate,
                utilization
            );
        }
        return self.maxRate;
    }

    function accumulate(
        UJumpRateUtilizationCurve6 memory self,
        UFixed6 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed6 notional
    ) internal pure returns (UFixed6) {
        return compute(self, utilization)
            .mul(UFixed6Lib.from(toTimestamp - fromTimestamp))
            .mul(notional)
            .div(UFixed6Lib.from(365 days));
    }
}

library UJumpRateUtilizationCurve6StorageLib {
    function read(UJumpRateUtilizationCurve6Storage self) internal view returns (UJumpRateUtilizationCurve6 memory) {
        return _storagePointer(self);
    }

    function store(UJumpRateUtilizationCurve6Storage self, UJumpRateUtilizationCurve6 memory value) internal {
        UJumpRateUtilizationCurve6 storage storagePointer = _storagePointer(self);

        storagePointer.minRate = value.minRate;
        storagePointer.maxRate = value.maxRate;
        storagePointer.targetRate = value.targetRate;
        storagePointer.targetUtilization = value.targetUtilization;
    }

    function _storagePointer(UJumpRateUtilizationCurve6Storage self)
    private pure returns (UJumpRateUtilizationCurve6 storage pointer) {
        assembly ("memory-safe") { pointer.slot := self }
    }
}

