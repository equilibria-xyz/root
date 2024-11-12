// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/Instance.sol";

interface IMockFactory {
    function onlyCallableByInstance() external view;
}

contract MockInstance is Instance {
    string public name;

    function initialize(string calldata name_) external initializer(1) {
        __Instance__initialize();

        name = name_;
    }

    function initializeIncorrect() external {
        __Instance__initialize();
    }

    function callOnlyInstanceFunction() external view {
        IMockFactory(address(factory())).onlyCallableByInstance();
    }

    /// @dev This function can only be called by the factory owner
    function protectedFunctionOwner(string calldata name_) external onlyOwner {
        name = name_;
    }

    /// @dev This function can only be called by the factory
    function protectedFunctionFactory(string calldata name_) external onlyFactory {
        name = name_;
    }

    /// @dev This function can only be called when the factory is not paused
    function protectedFunctionPaused(string calldata name_) external whenNotPaused {
        name = name_;
    }
}
