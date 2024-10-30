// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IInstance.sol";
import "./Pausable.sol";

/// @title Factory
/// @notice An abstract factory that manages creates and manages instances
/// @dev Ownable and Pausable, and satisfies the IBeacon interface by default.
abstract contract Factory is IFactory, Ownable, Pausable {
    /// @notice The instances mapping storage slot
    bytes32 private constant INSTANCE_MAP_SLOT = keccak256("equilibria.root.Factory.instances");

    /// @notice The instance implementation address
    address public immutable implementation;

    /// @notice Constructs the contract
    /// @param implementation_ The instance implementation address
    constructor(address implementation_) { implementation = implementation_; }

    /// @notice Initializes the contract state
    function __Factory__initialize() internal onlyInitializer {
        __Ownable__initialize();
    }

    /// @notice Returns whether the instance is valid
    /// @param instance The instance to check
    /// @return Whether the instance is valid
    function instances(IInstance instance) public view returns (bool) {
        return _instances()[instance];
    }

    /// @notice Creates a new instance
    /// @dev Deploys a BeaconProxy with the this contract as the beacon
    /// @param data The initialization data
    /// @return newInstance The new instance
    function _create(bytes memory data) internal returns (IInstance newInstance) {
        newInstance = IInstance(address(new BeaconProxy(address(this), data)));
        _register(newInstance);
    }
    /// @notice Creates a new instance at a deterministic address
    /// @dev Deploys a BeaconProxy with the this contract as the beacon
    /// @param data The initialization data
    /// @param salt Used along with initialization data to determine a unique BeaconProxy address
    /// @return newInstance The new instance
    function _create2(bytes memory data, bytes32 salt) internal returns (IInstance newInstance) {
        newInstance = IInstance(address(new BeaconProxy{salt: salt}(address(this), data)));
        _register(newInstance);
    }

    // @notice Calculates the address at which the instance will be deployed
    // @dev Passes the proxy's creation code along with this factory's address
    // @param data The same initialization data used in the _create2 call
    // @param salt Used along with initialization data to determine a unique BeaconProxy address
    function _computeCreate2Address(bytes memory data, bytes32 salt) internal view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(BeaconProxy).creationCode,
            abi.encode(address(this), data)
        );
        return Create2.computeAddress(salt, keccak256(bytecode));
    }

    /// @notice Registers a new instance
    /// @dev Called by _create automatically, or can be called manually in an extending implementation
    /// @param newInstance The new instance
    function _register(IInstance newInstance) internal {
        _instances()[newInstance] = true;
        emit InstanceRegistered(newInstance);
    }

    /// @notice Returns the storage mapping for instances
    /// @return r The storage mapping for instances
    function _instances() private pure returns (mapping(IInstance => bool) storage r) {
        bytes32 slot = INSTANCE_MAP_SLOT;
        /// @solidity memory-safe-assembly
        assembly { r.slot := slot }
    }

    /// @notice Only allow the function by a valid instance
    modifier onlyInstance {
        if (!instances(IInstance(msg.sender))) revert FactoryNotInstanceError();
        _;
    }
}
