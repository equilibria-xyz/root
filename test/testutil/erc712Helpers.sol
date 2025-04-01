// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { Vm } from "forge-std/Vm.sol";
import { Common, CommonLib } from "src/verifier/types/Common.sol";
import { GroupCancellation, GroupCancellationLib } from "src/verifier/types/GroupCancellation.sol";

bytes32 constant EIP712_DOMAIN_SEPARATOR_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

function domainSeparator(address verifyingContract) pure returns (bytes32) {
    return keccak256(
        abi.encode(
            EIP712_DOMAIN_SEPARATOR_TYPEHASH,
            keccak256(bytes("Equilibria Root Unit Tests")),
            keccak256(bytes("1.0.0")),
            31337,
            verifyingContract
        )
    );
}

function signCommon(address verifyingContract, Common memory common, uint256 signerKey) pure returns (bytes memory signature) {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    bytes32 structHash = CommonLib.hash(common);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, keccak256(abi.encodePacked("\x19\x01", domainSeparator(verifyingContract), structHash)));
    return abi.encodePacked(r, s, v);
}

function signGroupCancellation(
  address verifyingContract,
  GroupCancellation memory groupCancellation,
  uint256 signerKey
) pure returns (bytes memory signature) {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    bytes32 structHash = GroupCancellationLib.hash(groupCancellation);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, keccak256(abi.encodePacked("\x19\x01", domainSeparator(verifyingContract), structHash)));
    return abi.encodePacked(r, s, v);
}
