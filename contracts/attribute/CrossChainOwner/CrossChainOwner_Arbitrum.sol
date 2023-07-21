// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import "../CrossChainOwnable/CrossChainOwnable_Arbitrum.sol";
import "./CrossChainOwner.sol";

/**
 * @title CrossChainOwner_Arbitrum
 * @notice Contract to act as an owner of other contracts
 * @dev This contract is designed to act as an owner of any Ownable contract, allowing
 *      Cross Chain Ownership without modification to the underlying ownable contract. This contract
 *      is specific to the Arbitrum L2-side and should not be used on other chains.
 *
 *      See {CrossChainOwner.sol} for initialization and usage.
 */
contract CrossChainOwner_Arbitrum is CrossChainOwner, CrossChainOwnable_Arbitrum { }
