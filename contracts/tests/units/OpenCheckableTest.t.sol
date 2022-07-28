// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenCheckable.sol";
import "OpenNFTs/contracts/OpenERC165.sol";

abstract contract OpenCheckableTest is Test {
    address private _contract;
    address private _owner = address(0x1);

    bytes4 idIERC165 = type(IERC165).interfaceId;
    bytes4 idOpenCheckable = type(IOpenCheckable).interfaceId;
    bytes4 idNull = 0xffffffff;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenCheckable() public {
        _contract = constructorTest(_owner);
    }

    function testOpenCheckableSupportsInterface() public {
        assertTrue(IERC165(_contract).supportsInterface(idIERC165));
        assertTrue(IERC165(_contract).supportsInterface(idOpenCheckable));
        assertFalse(IERC165(_contract).supportsInterface(idNull));
    }

    function testOpenCheckableCheckSupportedInterfaces() public {
        bytes4[3] memory ids = [idIERC165, idOpenCheckable, idNull];
        bool[3] memory expected = [true, true, false];

        bytes4[] memory interfaceIds = new bytes4[](3);
        for (uint256 i = 0; i < ids.length; i++) {
            interfaceIds[i] = ids[i];
        }

        bool[] memory checks = IOpenCheckable(_contract).checkSupportedInterfaces(interfaceIds);

        for (uint256 i = 0; i < ids.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }
}
