// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev TODO
 */
abstract contract UInitializable {
    error UInitializableCalledFromConstructorError();
    error UInitializableAlreadyInitializedError();
    error UInitializableNotInitializingError();

    /// @dev unstructured storage slot for the initialized flag
    bytes32 private constant INITIALIZED_SLOT = keccak256("equilibria.utils.UInitializable.initialized");

    /// @dev unstructured storage slot for the initializing flag
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.utils.UInitializable.initializing");

    /// @dev TODO
    modifier initializer() {
        if (_isConstructor()) revert UInitializableCalledFromConstructorError();
        if (_initialized()) revert UInitializableAlreadyInitializedError();

        _setInitializing(true);
        _setInitialized(true);

        _;

        _setInitializing(false);
    }

    /// @dev TODO
    modifier onlyInitializer() {
        // either call from a constructor or from an initializer
        if (!_isConstructor() && !_initializing())
            revert UInitializableNotInitializingError();
        _;
    }

    /**
     * @notice Returns whether the contract has been initialized
     * @return result Initialized flag
     */
    function _initialized() private view returns (bool result) {
        bytes32 slot = INITIALIZED_SLOT;
        assembly {
            result := sload(slot)
        }
    }

    /**
     * @notice Returns whether the contract is currently being initialized
     * @return result Initializing flag
     */
    function _initializing() private view returns (bool result) {
        bytes32 slot = INITIALIZING_SLOT;
        assembly {
            result := sload(slot)
        }
    }

    /**
     * @notice Sets the initialized flag in unstructured storage
     * @dev Internal helper
     * @param newInitialized New initialized flag to store
     */
    function _setInitialized(bool newInitialized) private {
        bytes32 slot = INITIALIZED_SLOT;
        assembly {
            sstore(slot, newInitialized)
        }
    }

    /**
     * @notice Sets the initializing flag in unstructured storage
     * @dev Internal helper
     * @param newInitializing New initializing flag to store
     */
    function _setInitializing(bool newInitializing) private {
        bytes32 slot = INITIALIZING_SLOT;
        assembly {
            sstore(slot, newInitializing)
        }
    }

    /**
     * @notice Returns whether the code is currently being called from a constructor.
     * @dev Internal helper, see {Address.isContract} for explanation of mechanics
     * @return Whether the code is currently being called from a constructor
     */
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}
