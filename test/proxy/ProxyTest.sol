// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { IERC1967 } from "@openzeppelin/contracts/interfaces/IERC1967.sol";

import { RootTest } from "../../test/RootTest.sol";
import { Ownable } from "../../src/attribute/Ownable.sol";
import { IProxy } from "../../src/proxy/interfaces/IProxy.sol";
import { Proxy, ProxyAdmin } from "../../src/proxy/Proxy.sol";
import { Version } from "../../src/attribute/types/Version.sol";

/// @dev Tests both Proxy and ProxyAdmin
abstract contract ProxyTest is RootTest {
    address public immutable proxyOwner;
    address public immutable implementationOwner;
    IProxy public proxy;
    ProxyAdmin public proxyAdmin;
    SampleContractV1 impl1;
    SampleContractV1 public instance1;

    constructor() {
        proxyOwner = makeAddr("owner");
        implementationOwner = makeAddr("implementationOwner");
    }

    function setUp() public virtual {
        // create the proxy admin
        proxyAdmin = new ProxyAdmin();
        Version memory proxyAdminVersion = proxyAdmin.version();
        vm.startPrank(proxyOwner);
        proxyAdmin.initialize("");

        // deploy the implementation and create the proxy
        impl1 = new SampleContractV1(101);
        Proxy proxyInstantiation = new Proxy(
            impl1,
            proxyAdmin,
            abi.encodeCall(SampleContractV1.initialize, (""))
        );
        vm.stopPrank();
        proxy = IProxy(address(proxyInstantiation));

        // initialize the instance
        instance1 = SampleContractV1(address(proxy));

        changeOwner(implementationOwner);
    }

    function changeOwner(address newOwner) internal {
        vm.prank(proxyOwner);
        instance1.updatePendingOwner(implementationOwner);
        vm.prank(newOwner);
        instance1.acceptOwner();
    }

    function upgrade() internal returns (SampleContractV2) {
        return upgradeWithVersion(Version(2, 0, 1));
    }

    function upgradeWithVersion(Version memory version) internal returns (SampleContractV2) {
        SampleContractV2 impl2 = new SampleContractV2(201);
        vm.prank(proxyOwner);
        vm.expectEmit();
        emit IERC1967.Upgraded(address(impl2));
        proxyAdmin.upgradeToAndCall(
            proxy,
            impl2,
            abi.encodeCall(
                SampleContractV2.initialize,
                (abi.encode(int256(222)))
            )
        );
        return SampleContractV2(address(proxy));
    }
}

/// @dev Initial implementation of an upgradable contract
contract SampleContractV1 is Ownable {
    uint256 public immutable immutableValue;
    uint256 public value;

    constructor(uint256 immutableValue_)
        Ownable("SampleContract", Version(1, 0, 1), Version(0, 0, 0))
    {
        immutableValue = immutableValue_;
    }

    function initialize(bytes memory)
        external virtual override initializer(Version(1, 0, 1))
    {
        __Ownable__initialize();
        value = 112;
    }

    function setValue(uint256 value_) external onlyOwner() {
        value = value_;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}

/// @dev Second implementation of an upgradable contract
contract SampleContractV2 is Ownable {
    uint256 public immutable immutableValue;
    uint256 public value1; // same storage location as `value` in V1
    int256 public value2;

    error CustomError();

    constructor(uint256 immutableValue_)
        Ownable("SampleContract", Version(2, 0, 1), Version(1, 0, 1))
    {
        immutableValue = immutableValue_;
    }

    function initialize(bytes memory initParams)
        external virtual override initializer(Version(2, 0, 1))
    {
        // __Ownable__initialize() was already called in V1
        value1 += 1;
        value2 = abi.decode(initParams, (int256));
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
contract SampleContractWithOldInit is Ownable {
    uint256 public immutable immutableValue;
    uint256 public value1; // no storage change between V2.0.1 and V2.0.2
    int256 public value2;

    constructor(uint256 immutableValue_)
        Ownable("SampleContract", Version(2, 0, 2), Version(2, 0, 1))
    {
        immutableValue = immutableValue_;
    }

    // intentionally does not match contract
    function initialize(bytes memory)
        external virtual override initializer(Version(2, 0, 1))
    {
        // __Ownable__initialize() was already called in V1
        value1 = 676;
        value2 = -767;
    }
}

/// @dev Contract whose name does not match that expected by the proxy
contract NonSampleContract is Ownable {
    constructor() Ownable("NonSampleContract", Version(1, 1, 0), Version (1, 0, 0)) {}

    function initialize(bytes memory)
        external virtual override initializer(Version(1, 1, 0))
    {
        __Ownable__initialize();
    }
}
