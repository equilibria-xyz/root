// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/Factory.sol";
import "./MockInstance.sol";

contract MockFactory is Factory {
    constructor(address implementation_) Factory(implementation_) {}

    function initialize() external initializer(1) {
        __Factory__initialize();
    }

    function create(string calldata name) external onlyOwner returns (MockInstance) {
        return MockInstance(address(_create(abi.encodeCall(MockInstance.initialize, (name)))));
    }

    function create2(string calldata name, bytes32 salt) external onlyOwner returns (MockInstance) {
        return MockInstance(address(_create2(abi.encodeCall(MockInstance.initialize, (name)), salt)));
    }

    function computeCreate2Address(string calldata name, bytes32 salt) external view returns (address) {
        return _computeCreate2Address(abi.encodeCall(MockInstance.initialize, (name)), salt);
    }

    function onlyCallableByInstance() external view onlyInstance {}
}
