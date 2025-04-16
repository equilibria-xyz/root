// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

// TODO: lib with comparison

interface IInitializable {
    // sig: 0xd6f0e837
    /// @custom:error Contract is already initialized
    error InitializableAlreadyInitializedError();

    // sig: 0xb9a621e1
    /// @custom:error Contract is not initializing
    error InitializableNotInitializingError();

    event Initialized();
}
