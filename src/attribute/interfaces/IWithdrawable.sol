// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

import { Token18 } from "../../token/types/Token18.sol";
import { IAttribute } from "./IAttribute.sol";
import { IOwnable } from "./IOwnable.sol";

interface IWithdrawable is IAttribute, IOwnable {
    function withdraw(Token18 token) external;
}
