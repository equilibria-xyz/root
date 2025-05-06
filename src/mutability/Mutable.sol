// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IMutable } from "./interfaces/IMutable.sol";
import { Contract } from "./Contract.sol";

/// @title Mutable
/// @notice Implementation of Contract for upgradeable contracts.
abstract contract Mutable is IMutable, Contract {
    /// @custom:storage-location erc7201:equilibria.root.Mutable
    struct MutableStorage {
        uint256 version;
        bool constructing;
    }

    /// @dev The erc7201 storage location of the mix-in
    bytes32 private constant MutableStorageLocation = 0xb906736fa3fc696e6c19a856e0f8737e348fda5c7f33a32db99da3b92f19a800;

    /// @dev The erc7201 storage of the mix-in
    function Mutable$() private pure returns (MutableStorage storage $) {
        assembly {
            $.slot := MutableStorageLocation
        }
    }

    /// @dev Called at upgrade time to initialize the contract with `data`.
    function construct(bytes memory data) external {
        Mutable$().constructing = true;
        uint256 version = __constructor(data);
        Mutable$().constructing = false;

        if (Mutable$().version >= version) revert MutableVersionAlreadyInitialized();
        Mutable$().version = version;
        emit Initialized(version);
    }

    /// @dev Whether the contract is initializing.
    function _constructing() internal view override returns (bool) {
        return Mutable$().constructing;
    }

    /// @dev Hook for inheriting contracts to construct the contract.
    function __constructor(bytes memory data) internal virtual returns (uint256 version);
}
