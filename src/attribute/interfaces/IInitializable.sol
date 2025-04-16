// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

struct Version {
    uint32 major;
    uint32 minor;
    uint32 patch;
}

// TODO: lib with comparison

interface IInitializable {
    // sig: 0xb9a621e1
    /// @custom:error Contract is not initializing
    error InitializableNotInitializingError();

    event Initialized();
}
