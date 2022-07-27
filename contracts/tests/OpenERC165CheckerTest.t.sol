// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IERC165Checker.sol";
import "OpenNFTs/contracts/OpenERC165.sol";

abstract contract OpenERC165CheckerTest is Test {
    address private _contract;
    address private _owner = address(0x1);

    bytes4 idIERC165 = type(IERC165).interfaceId;
    bytes4 idIERC165Checker = type(IERC165Checker).interfaceId;
    bytes4 idNull = 0xffffffff;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpERC165Checker() public {
        _contract = constructorTest(_owner);
    }

    function testERC165CheckerSupportsInterface() public {
        assertTrue(IERC165(_contract).supportsInterface(idIERC165));
        assertTrue(IERC165(_contract).supportsInterface(idIERC165Checker));
        assertFalse(IERC165(_contract).supportsInterface(idNull));
    }

    function testERC165CheckerCheckSupportedInterfaces() public {
        bytes4[] memory interfaceIds = new bytes4[](3);
        interfaceIds[0] = idIERC165;
        interfaceIds[1] = idIERC165Checker;
        interfaceIds[2] = idNull;

        bool[] memory checks = IERC165Checker(_contract).checkSupportedInterfaces(interfaceIds);

        assertTrue(checks[0]);
        assertTrue(checks[1]);
        assertFalse(checks[2]);
    }
}
