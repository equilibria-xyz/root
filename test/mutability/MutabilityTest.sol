// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";

import { RootTest } from "../../test/RootTest.sol";
import { Ownable } from "../../src/attribute/Ownable.sol";
import { IMutable } from "../../src/mutability/interfaces/IMutable.sol";
import { Mutable } from "../../src/mutability/Mutable.sol";
import { Mutator } from "../../src/mutability/Mutator.sol";
import { Version, VersionLib } from "../../src/mutability/types/Version.sol";
import { Implementation } from "../../src/mutability/Implementation.sol";
import { IImplementation } from "../../src/mutability/interfaces/IImplementation.sol";
import { IMutableTransparent } from "../../src/mutability/interfaces/IMutable.sol";
import { IOwnable } from "../../src/attribute/Ownable.sol";

/// @dev Creates Mutator and owner but does not deploy anything in setup
abstract contract MutableTest is RootTest {
    address public immutable owner;
    Mutator public mutator;
    IMutable public mutableContract;

    constructor() {
        owner = makeAddr("owner");
    }

    function setUp() public virtual {
        // create and initialize the mutator
        vm.startPrank(owner);
        mutator = new Mutator();
        vm.stopPrank();
    }

    function deploy(IImplementation impl) public virtual {
        vm.prank(owner);
        IMutableTransparent newMutable = mutator.create(impl.name(), impl, "");
        mutableContract = IMutable(address(newMutable));
    }
}

/// @dev Tests both Mutable and Mutator
abstract contract MutableTestV1Deploy is MutableTest {
    address public immutable implementationOwner;
    SampleContractV1 public impl1;
    SampleContractV1 public instance1;

    constructor() MutableTest() {
        implementationOwner = makeAddr("implementationOwner");
    }

    function setUp() public virtual override (MutableTest) {
        super.setUp();

        // deploy the implementation and create the mutable
        vm.startPrank(owner);
        impl1 = new SampleContractV1(101);
        IMutableTransparent newMutable = mutator.create(impl1.name(), impl1, "");
        mutableContract = IMutable(address(newMutable));
        vm.stopPrank();

        // initialize the instance
        instance1 = SampleContractV1(address(mutableContract));

        changeOwner(implementationOwner);
    }

    function changeOwner(address newOwner) internal {
        vm.prank(owner);
        IOwnable(address(mutableContract)).updatePendingOwner(newOwner);
        vm.prank(newOwner);
        IOwnable(address(mutableContract)).acceptOwner();
    }

    function upgrade() internal returns (SampleContractV2) {
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(owner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        mutator.upgrade(
            impl2.name(),
            impl2,
            abi.encode(uint256(222))
        );
        return SampleContractV2(address(mutableContract));
    }
}

/// @dev Initial implementation of an upgradable contract
contract SampleContractV1 is Implementation, Ownable {
    uint256 public immutable immutableValue;
    uint256 public value;

    function name() public pure override returns (string memory) { return "SampleContractV1"; }

    constructor(uint256 immutableValue_) Implementation(VersionLib.from(1, 0, 1), VersionLib.from(0, 0, 0)) {
        immutableValue = immutableValue_;
    }

    function __constructor(bytes memory) internal override returns (Version) {
        __Ownable__constructor();

        value = 112;

        return VersionLib.from(1, 0, 1);
    }

    function setValue(uint256 value_) external onlyOwner() {
        value = value_;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}

/// @dev Second implementation of an upgradable contract
contract SampleContractV2 is Implementation, Ownable {
    function name() public pure override returns (string memory) { return "SampleContractV2"; }

    uint256 public immutable immutableValue;
    uint256 public value1; // same storage location as `value` in V1
    int256 public value2;

    error CustomError();

    constructor(uint256 immutableValue_) Implementation(VersionLib.from(2, 0, 1), VersionLib.from(1, 0, 1)) {
        immutableValue = immutableValue_;
    }

    function __constructor(bytes memory initParams) internal override returns (Version) {
        // __Ownable__initialize() was already called in V1

        value1 += 1;
        value2 = abi.decode(initParams, (int256));

        return VersionLib.from(2, 0, 1);
    }

    function setValues(uint256 value1_, int256 value2_) external onlyOwner() {
        value1 = value1_;
        value2 = value2_;
    }

    function getValues() external view returns (uint256, int256) {
        return (value1, value2);
    }

    function revertWhenCalled() external pure {
        revert CustomError();
    }
}

/// @dev Initialize version is still 2.0.1, so initializer should not run
contract SampleContractWithOldInit is Implementation, Ownable {
    function name() public pure override returns (string memory) { return "SampleContractV2"; }

    uint256 public immutable immutableValue;
    uint256 public value1; // no storage change between V2.0.1 and V2.0.2
    int256 public value2;

    constructor(uint256 immutableValue_) Implementation(VersionLib.from(2, 0, 2), VersionLib.from(2, 0, 1)) {
        immutableValue = immutableValue_;
    }

    function __constructor(bytes memory) internal override returns (Version) {
        // __Ownable__constructor() was already called in V1

        value1 = 676;
        value2 = -767;

        return VersionLib.from(2, 0, 1); // intentionally does not match contract
    }
}

/// @dev Contract whose name does not match that expected by the mutable
contract NonSampleContract is Implementation, Ownable {
    function name() public pure override returns (string memory) { return "NonSampleContract"; }  // intentionally does not match contract

    constructor() Implementation(VersionLib.from(1, 1, 0), VersionLib.from(1, 0, 0)) {}

    function __constructor(bytes memory) internal override returns (Version) {
        __Ownable__constructor();

        return VersionLib.from(1, 1, 0);
    }
}
