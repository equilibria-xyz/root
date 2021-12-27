// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 *
 * NOTE: This contract has been extended from the Open Zeppelin library to include an
 *       unstructured storage pattern, so that it can be safely mixed in with upgradeable
 *       contracts without affecting their storage patterns through inheritance.
 */
abstract contract UInitializable {
    error UInitializableAlreadyInitializedError();
    error UInitializableNotInitializingError();

    /// @dev unstructured storage slot for the initialized flag
    bytes32 private constant INITIALIZED_SLOT = keccak256("equilibria.utils.UInitializable.initialized");

    /// @dev unstructured storage slot for the initializing flag
    bytes32 private constant INITIALIZING_SLOT = keccak256("equilibria.utils.UInitializable.initializing");

    /// @dev Modifier to protect an initializer function from being invoked twice.
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        if (_initializing() ? !_isConstructor() : _initialized()) revert UInitializableAlreadyInitializedError();

        bool isTopLevelCall = !_initializing();
        if (isTopLevelCall) {
            _setInitializing(true);
            _setInitialized(true);
        }

        _;

        if (isTopLevelCall) {
            _setInitializing(false);
        }
    }

    /// @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
    /// {initializer} modifier, directly or indirectly.
    modifier onlyInitializing() {
        if (!_initializing()) revert UInitializableNotInitializingError();
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
