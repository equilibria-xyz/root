// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/crosschain/arbitrum/CrossChainEnabledArbitrumL2.sol";
import "./UCrossChainOwnable.sol";

/**
 * @title UCrossChainOwnable_Arbitrum
 * @notice Library to manage the cross-chain ownership lifecycle of Arbitrum upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance. This contract
 *      is specific to the Arbitrum L2-side and should not be used on other chains.
 *
 *      See {UCrossChainOwnable} for initialization and update usage.
 */
abstract contract UCrossChainOwnable_Arbitrum is CrossChainEnabledArbitrumL2, UCrossChainOwnable {
    constructor() CrossChainEnabledArbitrumL2() {}
}
