// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { IInstance } from "src/attribute/interfaces/IInstance.sol";
import { IFactory } from "src/attribute/interfaces/IFactory.sol";
import { Initializable } from "src/attribute/Initializable.sol";

/// @title Instance
/// @notice An abstract contract that is created and managed by a factory
abstract contract Instance is IInstance, Initializable {
    /// @dev The factory address storage slot
    address private _factory;

    /// @notice Returns the factory that created this instance
    /// @return The factory that created this instance
    function factory() public view returns (IFactory) { return IFactory(_factory); }

    /// @notice Initializes the contract setting `msg.sender` as the factory
    function __Instance__initialize() internal onlyInitializer {
        _factory = msg.sender;
    }

    /// @notice Only allow the owner defined by the factory to call the function
    modifier onlyOwner {
        if (msg.sender != factory().owner()) revert InstanceNotOwnerError(msg.sender);
        _;
    }

    /// @notice Only allow the factory to call the function
    modifier onlyFactory {
        if (msg.sender != address(factory())) revert InstanceNotFactoryError(msg.sender);
        _;
    }

    /// @notice Only allow the function to be called when the factory is not paused
    modifier whenNotPaused {
        if (factory().paused()) revert InstancePausedError();
        _;
    }
}
