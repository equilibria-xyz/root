// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IInitializable {
    // sig: 0x3db738da
    /// @custom:error Contract is already initialized
    error InitializableAlreadyInitializedError(uint256 version);

    // sig: 0xb9a621e1
    /// @custom:error Contract is not initializing
    error InitializableNotInitializingError();

    event Initialized(uint256 version);
}
