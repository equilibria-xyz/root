// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

type Version is uint256;
using VersionLib for Version global;

using {
    eq as ==,
    neq as !=,
    gt as >,
    lt as <
} for Version global;
using {
    eq,
    neq,
    gt,
    lt
} for Version global;

library VersionLib {
    // TODO: We're wasting a lot of unused bytes here.  Should this be a uint96?
    // Or should we reserve a different number of bytes for each component? 85/85/86? 64/64/128?

    function from(
        uint32 major,
        uint32 minor,
        uint32 patch
    ) internal pure returns (Version) {
        return Version.wrap((uint256(major) << 64) | (uint256(minor) << 32) | uint256(patch));
    }

    function toComponents(Version self) internal pure returns (uint32 major, uint32 minor, uint32 patch) {
        uint256 value = Version.unwrap(self);
        major = uint32(value >> 64);
        minor = uint32(value >> 32 & 0xFFFFFFFF);
        patch = uint32(value & 0xFFFFFFFF);
    }

    /// @notice Compares two versions; returns 1 if equal, 2 if self > other, 0 if self < other
    function compare(Version self, Version other) internal pure returns (uint256) {
        (uint32 selfMajor, uint32 selfMinor, uint32 selfPatch) = self.toComponents();
        (uint32 otherMajor, uint32 otherMinor, uint32 otherPatch) = other.toComponents();
        if (selfMajor != otherMajor) {
            return selfMajor > otherMajor ? 2 : 0;
        }
        if (selfMinor != otherMinor) {
            return selfMinor > otherMinor ? 2 : 0;
        }
        if (selfPatch != otherPatch) {
            return selfPatch > otherPatch ? 2 : 0;
        }
        return 1;
    }
}

/// @notice Returns whether version `a` is equal to `b`
/// @param a First version
/// @param b Second version
/// @return Whether `a` is equal to `b`
function eq(Version a, Version b) pure returns (bool) {
    return Version.unwrap(a) == Version.unwrap(b);
}

function neq(Version a, Version b) pure returns (bool) {
    return !eq(a, b);
}

/// @notice Returns whether version `a` is greater than `b`
/// @param a First version
/// @param b Second version
/// @return Whether `a` is greater than `b`
function gt(Version a, Version b) pure returns (bool) {
    return VersionLib.compare(a, b) == 2;
}

/// @notice Returns whether version `a` is less than `b`
/// @param a First version
/// @param b Second version
/// @return Whether `a` is less than `b`
function lt(Version a, Version b) pure returns (bool) {
    return VersionLib.compare(a, b) == 0;
}

