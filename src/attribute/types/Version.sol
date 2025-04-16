// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

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

// TODO: unit tests
library VersionLib {
    // TODO: Is this needed/useful?
    function toString(Version memory self) internal pure returns (string memory) {
        return string(abi.encodePacked(self.major, ".", self.minor, ".", self.patch));
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
