// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CurveMath18.sol";
import "../../number/types/PackedUFixed18.sol";
import "../../number/types/PackedFixed18.sol";

/// @dev UJumpRateUtilizationCurve18 type
struct UJumpRateUtilizationCurve18 {
    PackedUFixed18 minRate;
    PackedUFixed18 maxRate;
    PackedUFixed18 targetRate;
    PackedUFixed18 targetUtilization;
}
using UJumpRateUtilizationCurve18Lib for UJumpRateUtilizationCurve18 global;
type UJumpRateUtilizationCurve18Storage is bytes32;
using UJumpRateUtilizationCurve18StorageLib for UJumpRateUtilizationCurve18Storage global;

/**
 * @title UJumpRateUtilizationCurve18Lib
 * @notice Library for the unsigned Jump Rate utilization curve type
 */
library UJumpRateUtilizationCurve18Lib {
    /**
     * @notice Computes the corresponding rate for a utilization ratio
     * @param utilization The utilization ratio
     * @return The corresponding rate
     */
    function compute(UJumpRateUtilizationCurve18 memory self, UFixed18 utilization) internal pure returns (UFixed18) {
        UFixed18 targetUtilization = self.targetUtilization.unpack();
        if (utilization.lt(targetUtilization)) {
            return CurveMath18.linearInterpolation(
                UFixed18Lib.ZERO,
                self.minRate.unpack(),
                targetUtilization,
                self.targetRate.unpack(),
                utilization
            );
        }
        if (utilization.lt(UFixed18Lib.ONE)) {
            return CurveMath18.linearInterpolation(
                targetUtilization,
                self.targetRate.unpack(),
                UFixed18Lib.ONE,
                self.maxRate.unpack(),
                utilization
            );
        }
        return self.maxRate.unpack();
    }

    function accumulate(
        UJumpRateUtilizationCurve18 memory self,
        UFixed18 utilization,
        uint256 fromTimestamp,
        uint256 toTimestamp,
        UFixed18 notional
    ) internal pure returns (UFixed18) {
        return compute(self, utilization)
            .mul(UFixed18Lib.from(toTimestamp - fromTimestamp))
            .mul(notional)
            .div(UFixed18Lib.from(365 days));
    }
}

library UJumpRateUtilizationCurve18StorageLib {
    function read(UJumpRateUtilizationCurve18Storage self) internal view returns (UJumpRateUtilizationCurve18 memory) {
        return _storagePointer(self);
    }

    function store(UJumpRateUtilizationCurve18Storage self, UJumpRateUtilizationCurve18 memory value) internal {
        UJumpRateUtilizationCurve18 storage storagePointer = _storagePointer(self);

        storagePointer.minRate = value.minRate;
        storagePointer.maxRate = value.maxRate;
        storagePointer.targetRate = value.targetRate;
        storagePointer.targetUtilization = value.targetUtilization;
    }

    function _storagePointer(UJumpRateUtilizationCurve18Storage self)
    private pure returns (UJumpRateUtilizationCurve18 storage pointer) {
        assembly ("memory-safe") { pointer.slot := self }
    }
}
