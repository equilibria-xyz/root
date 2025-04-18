// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

// TODO: Check code size making these each uint256s
struct Version {
    uint32 major;
    uint32 minor;
    uint32 patch;
}

using VersionLib for Version global;

// TODO: Operators can only be implemented for user-defined value types.(5332)
// Wondering if I should "type Version is uint96" and use bitwise operators instead.
/*using {
    eq as ==,
    gt as >,
    lt as <
} for Version global;*/
using {
    eq,
    gt,
    lt
} for Version global;

library VersionLib {
    function toUnsigned(Version memory self) internal pure returns (uint96) {
        return uint96((uint96(self.major) << 64) | uint96(self.minor) << 32 | self.patch);
    }

    /// @dev Converts single unsigned value to struct.  Only 96 bytes needed, but
    ///      storing as 256 for performance reasons.
    function from(uint256 value) internal pure returns (Version memory) {
        return Version(
            uint32(value >> 64),
            uint32((value >> 32) & 0xFFFFFFFF),
            uint32(value & 0xFFFFFFFF)
        );
    }

    /// @notice Compares two versions; returns 1 if equal, 2 if self > other, 0 if self < other
    function compare(Version memory self, Version memory other) internal pure returns (uint256) {
        if (self.major != other.major) {
            return self.major > other.major ? 2 : 0;
        }
        if (self.minor != other.minor) {
            return self.minor > other.minor ? 2 : 0;
        }
        if (self.patch != other.patch) {
            return self.patch > other.patch ? 2 : 0;
        }
        return 1;
    }
}

/// @notice Returns whether version `a` is equal to `b`
/// @param a First version
/// @param b Second version
/// @return Whether `a` is equal to `b`
function eq(Version memory a, Version memory b) pure returns (bool) {
    return VersionLib.compare(a, b) == 1;
}

/// @notice Returns whether version `a` is greater than `b`
/// @param a First version
/// @param b Second version
/// @return Whether `a` is greater than `b`
function gt(Version memory a, Version memory b) pure returns (bool) {
    return VersionLib.compare(a, b) == 2;
}

/// @notice Returns whether version `a` is less than `b`
/// @param a First version
/// @param b Second version
/// @return Whether `a` is less than `b`
function lt(Version memory a, Version memory b) pure returns (bool) {
    return VersionLib.compare(a, b) == 0;
}
