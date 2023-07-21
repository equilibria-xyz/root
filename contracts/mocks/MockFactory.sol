// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/Factory.sol";
import "./MockInstance.sol";

contract MockFactory is Factory {
    constructor(address implementation_) Factory(implementation_) {}

    function initialize() external initializer(1) {
        __Factory__initialize();
    }

    function create(string calldata name) external onlyOwner returns (MockInstance){
        return MockInstance(address(_create(abi.encodeCall(MockInstance.initialize, (name)))));
    }

    function onlyCallableByInstance() external view onlyInstance {}
}
