// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../control/unstructured/CrossChainOwnable/UCrossChainOwnable_Optimism.sol";

contract MockUCrossChainOwnable_Optimism is UCrossChainOwnable_Optimism {
    function __initialize(address owner) external initializer(1) {
        super.__UCrossChainOwnable__initialize(owner);
    }

    function mustOwner() public view onlyOwner returns (bool) {
        return true;
    }
}
