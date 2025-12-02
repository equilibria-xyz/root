// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";
import { IImplementation } from "./IImplementation.sol";

/// @dev The publicly available interface of the Mutable contract.
interface IMutableTransparent is IERC1967 {
    /// @dev Emitted when the mutable is paused to all external calls.
    event Paused();

    /// @dev Emitted when the mutable is unpaused for all external calls.
    event Unpaused();

    // sig: 0xeced32bc
    /// @dev An external call was made to the contract while the mutable was paused.
    /// @custom:error Version has already been initialized
    error PausedError();

    // sig: 0xcd38faf6
    /// @dev An external call was made to the contract while the mutable was paused.
    error UnpausedError();

    // sig: 0xa16b8f00
    /// @dev Mutator functionality was called by a non-mutator.
    error MutableDeniedMutatorAccess();

    // sig: 0x6faec855
    /// @dev The constructor was called directly.
    error MutableDeniedConstructorAccess();

    // sig: 0x172536eb
    /// @dev The predecessor version of the implementation does not match the previous implementation version.
    error MutablePredecessorMismatch();

    // sig: 0x9c01e6c8
    /// @dev The version of the implementation is already initialized.
    error MutableVersionMismatch();
}

/// @dev The interface of the Mutable contract with respect to the Mutator.
interface IMutable is IMutableTransparent {
    /// @dev Replaces the implementation, validating name and version
    /// @param newImplementation The new implementation contract
    /// @param data Calldata to invoke the instance's initializer
    function upgrade(IImplementation newImplementation, bytes calldata data) external;

    /// @dev Prevents any interaction with the proxied contract.
    /// Implementation may be upgraded when paused.
    function pause() external;

    /// @dev Allows interaction with the proxied contract
    function unpause() external;
}