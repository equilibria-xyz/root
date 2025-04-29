// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IMutable {
    // sig: TODO
    /// @custom:error Version is zero
    error MutableZeroVersionError();

    // sig: TODO
    /// @custom:error Contract is already initialized
    error MutableAlreadyInitializedError(uint256 version);

    event Initialized(uint256 version);
}
