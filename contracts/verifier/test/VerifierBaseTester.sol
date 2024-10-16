// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { VerifierBase } from "../VerifierBase.sol";

/// @dev Empty implementation for the sole purpose of testing base class
contract VerifierBaseTester is VerifierBase {
    constructor() EIP712("Equilibria Root Unit Tests", "1.0.0") { }
}
