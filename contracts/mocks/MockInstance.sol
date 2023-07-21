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

    function callOnlyInstanceFunction() external view {
        IMockFactory(address(factory())).onlyCallableByInstance();
    }

    /// @dev This function can only be called by the factory owner and when the factory is not paused
    function protectedFunction() external view onlyOwner whenNotPaused {}
}
