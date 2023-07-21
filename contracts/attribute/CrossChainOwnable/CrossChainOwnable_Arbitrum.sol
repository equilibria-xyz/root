// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/crosschain/arbitrum/CrossChainEnabledArbitrumL2.sol";
import "./CrossChainOwnable.sol";

/**
 * @title CrossChainOwnable_Arbitrum
 * @notice Library to manage the cross-chain ownership lifecycle of Arbitrum upgradeable contracts.
 * @dev This contract has been extended from the Open Zeppelin library to include an
 *      unstructured storage pattern so that it can be safely mixed in with upgradeable
 *      contracts without affecting their storage patterns through inheritance. This contract
 *      is specific to the Arbitrum L2-side and should not be used on other chains.
 *
 *      See {CrossChainOwnable.sol} for initialization and update usage.
 */
abstract contract CrossChainOwnable_Arbitrum is CrossChainEnabledArbitrumL2, CrossChainOwnable {
    constructor() CrossChainEnabledArbitrumL2() {}
}
