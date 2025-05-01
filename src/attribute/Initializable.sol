// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IInitializable } from "./interfaces/IInitializable.sol";

/// @title Initializable
/// @notice Library to manage the initialization lifecycle of upgradeable contracts
/// @dev `Initializable.sol` allows the creation of pseudo-constructors for upgradeable contracts. One
///      `initializer` should be declared per top-level contract. Child contracts can use the `onlyInitializer`
///      modifier to tag their internal initialization functions to ensure that they can only be called
///      from a top-level `initializer` or a constructor.
abstract contract Initializable is IInitializable {
    /// @custom:storage-location erc7201:equilibria.root.Initializable
    struct InitializableStorage {
        uint256 version;
        bool initializing;
    }

    /// @dev The erc7201 storage location of the mix-in
    // solhint-disable-next-line const-name-snakecase
    bytes32 private constant InitializableStorageLocation = 0x08f77ec4fbea51a32ec724cceb179b6666a9be3867a64cbf2c349790a85c2500;

    /// @dev The erc7201 storage of the mix-in
    function Initializable$() private pure returns (InitializableStorage storage $) {
        assembly {
            $.slot := InitializableStorageLocation
        }
    }

    /// @notice The slot of the initialized version
    bytes32 private constant VERSION_SLOT = keccak256("equilibria.root.Initializable.version");

    /// @notice The slot of the initializing flag
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.root.Initializable.initializing");

    /// @dev Can only be called once per version, `version` is 1-indexed
    modifier initializer(uint256 version) {
        if (version == 0) revert InitializableZeroVersionError();
        if (Initializable$().version >= version)
            revert InitializableAlreadyInitializedError(version);

        Initializable$().version = version;
        Initializable$().initializing = true;

        _;

        Initializable$().initializing = false;
        emit Initialized(version);
    }

    /// @dev Can only be called from an initializer or constructor
    modifier onlyInitializer() {
        if (!_constructing() && !Initializable$().initializing)
            revert InitializableNotInitializingError();
        _;
    }

    /// @notice Returns whether the contract is currently being constructed
    /// @return Whether the contract is currently being constructed
    function _constructing() private view returns (bool) {
        return !(address(this).code.length > 0);
    }
}
