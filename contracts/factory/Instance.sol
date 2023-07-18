// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../storage/UStorage.sol";
import "../control/unstructured/UInitializable.sol";
import "./IInstance.sol";

/**
 * @title UInstance
 * @notice
 * @dev
 */
abstract contract Instance is IInstance, UInitializable {
    /// @dev The factory address
    AddressStorage private constant _factory = AddressStorage.wrap(keccak256("equilibria.root.Instance.factory"));
    function factory() public view returns (IFactory) { return IFactory(_factory.read()); }

    /**
     * @notice Initializes the contract setting `msg.sender` as the initial owner
     */
    function __Instance__initialize() internal onlyInitializer {
        _factory.store(msg.sender);
    }

    modifier onlyOwner {
        if (msg.sender != factory().owner()) revert InstanceNotOwnerError(msg.sender);
        _;
    }

    modifier whenNotPaused {
        if (factory().paused()) revert InstancePausedError();
        _;
    }
}
