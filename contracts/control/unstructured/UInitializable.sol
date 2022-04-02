// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";
import "../../UStorage.sol";

/**
 * @title UInitializable
 * @notice Library to manage the initialization lifecycle of upgradeable contracts
 * @dev `UInitializable` allows the creation of pseudo-constructors for upgradeable contracts. One
 *      `initializer` should be declared per top-level contract. Child contracts can use the `onlyInitializer`
 *      modifier to tag their internal initialization functions to ensure that they can only be called
 *      from a top-level `initializer` or a constructor.
 */
abstract contract UInitializable is UStorage {
    error UInitializableCalledFromConstructorError();
    error UInitializableAlreadyInitializedError();
    error UInitializableNotInitializingError();

    /// @dev The initialized flag
    bytes32 private constant INITIALIZED_SLOT = keccak256("equilibria.root.UInitializable.initialized");
    function _initialized() private view returns (bool) { return _readBool(INITIALIZED_SLOT); }
    function _setInitialized(bool newInitialized) private { _write(INITIALIZED_SLOT, newInitialized); }

    /// @dev The initializing flag
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.root.UInitializable.initializing");
    function _initializing() private view returns (bool) { return _readBool(INITIALIZING_SLOT); }
    function _setInitializing(bool newInitializing) private { _write(INITIALIZING_SLOT, newInitializing); }

    /// @dev Can only be called once, and cannot be called from another initializer or constructor
    modifier initializer() {
        if (_constructing()) revert UInitializableCalledFromConstructorError();
        if (_initialized()) revert UInitializableAlreadyInitializedError();

        _setInitializing(true);
        _setInitialized(true);

        _;

        _setInitializing(false);
    }

    /// @dev Can only be called from an initializer or constructor
    modifier onlyInitializer() {
        if (!_constructing() && !_initializing())
            revert UInitializableNotInitializingError();
        _;
    }

    /**
     * @notice Returns whether the contract is currently being constructed
     * @dev {Address.isContract} returns false for contracts currently in the process of being constructed
     * @return Whether the contract is currently being constructed
     */
    function _constructing() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}
