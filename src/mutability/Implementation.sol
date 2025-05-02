// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IImplementation } from "./interfaces/IImplementation.sol";
import { Contract } from "./Contract.sol";

/// @title Implementation
/// @notice Implementation of Contract for upgradeable contracts.
abstract contract Implementation is IImplementation, Contract {
    /// @custom:storage-location erc7201:equilibria.root.Implementation
    struct ImplementationStorage {
        uint256 version;
        bool constructing;
    }

    /// @dev The erc7201 storage location of the mix-in
    bytes32 private constant ImplementationStorageLocation = 0x3c57b102c533ff058ebe9a7c745178ce4174563553bb3edde7874874c532c200;

    /// @dev The erc7201 storage of the mix-in
    function Implementation$() private pure returns (ImplementationStorage storage $) {
        assembly {
            $.slot := ImplementationStorageLocation
        }
    }

    /// @dev Called at upgrade time to initialize the contract with `data`.
    function construct(bytes memory data) external {
        Implementation$().constructing = true;
        uint256 version = __constructor(data);
        Implementation$().constructing = false;

        if (Implementation$().version >= version) revert ImplementationVersionAlreadyInitialized();
        Implementation$().version = version;
        emit Initialized(version);
    }

    /// @dev Whether the contract is initializing.
    function _constructing() internal view override returns (bool) {
        return Implementation$().constructing;
    }

    /// @dev Hook for inheriting contracts to construct the contract.
    function __constructor(bytes memory data) internal virtual returns (uint256 version);
}
