// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../storage/Storage.sol";
import "./interfaces/IInstance.sol";
import "./Initializable.sol";

/// @title Instance
/// @notice An abstract contract that is created and managed by a factory
abstract contract Instance is IInstance, Initializable {
    /// @dev The factory address storage slot
    AddressStorage private constant _factory = AddressStorage.wrap(keccak256("equilibria.root.Instance.factory"));

    /// @notice Returns the factory that created this instance
    /// @return The factory that created this instance
    function factory() public view returns (IFactory) { return IFactory(_factory.read()); }

    /// @notice Initializes the contract setting `msg.sender` as the factory
    function __Instance__initialize() internal onlyInitializer {
        _factory.store(msg.sender);
    }

    /// @notice Only allow the owner defined by the factory to call the function
    modifier onlyOwner {
        if (msg.sender != factory().owner()) revert InstanceNotOwnerError(msg.sender);
        _;
    }

    /// @notice Only allow the function to be called when the factory is not paused
    modifier whenNotPaused {
        if (factory().paused()) revert InstancePausedError();
        _;
    }
}
