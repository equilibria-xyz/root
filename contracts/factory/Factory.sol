// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "./IFactory.sol";
import "../control/unstructured/UPausable.sol";
import "./IInstance.sol";

/**
 * @title Factory
 * @notice
 * @dev
 */
abstract contract Factory is IFactory, UOwnable, UPausable {
    bytes32 private constant INSTANCE_MAP_SLOT = keccak256("equilibria.root.Factory.instances");

    /// @dev Satisfies the IBeacon interface
    address public immutable implementation;

    constructor(address implementation_) { implementation = implementation_; }

    function __Factory__initialize() internal onlyInitializer {
        __UOwnable__initialize();
    }

    function instances(IInstance instance) public view returns (bool) {
        return _instances()[instance];
    }

    function _create(bytes memory data) internal returns (IInstance newInstance) {
        newInstance = IInstance(address(new BeaconProxy(address(this), data)));
        _instances()[newInstance] = true;
        emit InstanceCreated(newInstance);
    }

    function _instances() private pure returns (mapping(IInstance => bool) storage r) {
        bytes32 slot = INSTANCE_MAP_SLOT;
        /// @solidity memory-safe-assembly
        assembly { r.slot := slot }
    }

    modifier onlyInstance {
        if (!instances(IInstance(msg.sender))) revert FactoryNotInstanceError();
        _;
    }
}
