// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

interface IMutable {
    // sig: 0xf74492ff
    /// @custom:error Version has already been initialized
    error MutableVersionAlreadyInitialized();

    event Initialized(uint256 version);

    function construct(bytes memory data) external;
}
