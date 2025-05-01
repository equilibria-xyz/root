// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

type Version is bytes32;
using VersionLib for Version global;

using {
    eq as ==,
    neq as !=
} for Version global;
using {
    eq,
    neq
} for Version global;

library VersionLib {
    function from(uint32 major, uint32 minor, uint32 patch) internal pure returns (Version) {
        return Version.wrap(bytes32((uint256(major) << 64) | (uint256(minor) << 32) | uint256(patch)));
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
