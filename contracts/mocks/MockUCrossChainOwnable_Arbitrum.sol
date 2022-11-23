// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../control/unstructured/CrossChainOwnable/UCrossChainOwnable_Arbitrum.sol";

contract MockUCrossChainOwnable_Arbitrum is UCrossChainOwnable_Arbitrum {
    function __initialize() external initializer(1) {
        super.__UOwnable__initialize();
    }

    function mustOwner() public view onlyOwner returns (bool) {
        return true;
    }
}
