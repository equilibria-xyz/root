// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../attribute/CrossChainOwnable/CrossChainOwnable_Optimism.sol";

contract MockCrossChainOwnable_Optimism is CrossChainOwnable_Optimism {
    function __initialize() external initializer(1) {
        super.__UOwnable__initialize();
    }

    function mustOwner() public view onlyOwner returns (bool) {
        return true;
    }
}
