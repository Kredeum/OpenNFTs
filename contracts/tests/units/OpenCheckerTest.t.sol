// SPDX-License-Identifier: MITs
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/examples/OpenNFTsEx.sol";
import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IOpenChecker.sol";

abstract contract OpenCheckerTest is Test {
    address private _resolver;
    address private _owner = address(0x1);
    address[3] private _addrs;

    bytes4 private _idNull = 0xffffffff;
    bytes4 private _idIERC165 = type(IERC165).interfaceId;
    bytes4 private _idChecker = type(IOpenChecker).interfaceId;

    function constructorTest(address owner_) public virtual returns (address);

    function setUpOpenChecker() public {
        _resolver = constructorTest(_owner);

        bool[] memory options = new bool[](1);
        options[0] = true;

        OpenNFTsEx openNFTsEx = new OpenNFTsEx();
        openNFTsEx.initialize("OpenNFTsEx", "NFT", _owner, options);
        _addrs[0] = address(openNFTsEx);

        OpenNFTsEx openNFTsEx2 = new OpenNFTsEx();
        openNFTsEx2.initialize("OpenNFTsEx2", "NFT2", _owner, options);
        _addrs[1] = address(openNFTsEx2);

        _addrs[2] = _resolver;
    }

    function testOpenCheckerIsCollection() public {
        assertTrue(IOpenChecker(_resolver).isCollection(_addrs[0]));
        assertTrue(IOpenChecker(_resolver).isCollection(_addrs[1]));
        assertFalse(IOpenChecker(_resolver).isCollection(_addrs[2]));
    }

    function testOpenCheckerIsCollections() public {
        address[] memory addrs = new address[](3);
        addrs[0] = _addrs[0];
        addrs[1] = _addrs[1];
        addrs[2] = _addrs[2];

        bool[3] memory expected = [true, true, false];
        bool[] memory checks = IOpenChecker(_resolver).isCollections(addrs);

        for (uint256 i = 0; i < expected.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }

    function testOpenCheckerSupportsInterface() public {
        assertFalse(IERC165(_resolver).supportsInterface(_idNull));
        assertTrue(IERC165(_resolver).supportsInterface(_idIERC165));
        assertTrue(IERC165(_resolver).supportsInterface(_idChecker));
    }

    function testOpenCheckerErcSupportedInterfaces() public {
        bool[11] memory expected =
            [false, true, false, false, false, false, false, false, false, true, false];

        bool[] memory checks = IOpenChecker(_resolver).checkErcInterfaces(_resolver);

        for (uint256 i = 0; i < checks.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }

    function testOpenCheckerCheckSupportedInterfaces() public {
        bytes4[2] memory ids = [_idIERC165, _idNull];
        bool[2] memory expected = [true, false];

        bytes4[] memory interfaceIds = new bytes4[](2);
        for (uint256 i = 0; i < ids.length; i++) {
            interfaceIds[i] = ids[i];
        }

        bool[] memory checks =
            IOpenChecker(_resolver).checkSupportedInterfaces(_resolver, false, interfaceIds);

        for (uint256 i = 0; i < ids.length; i++) {
            assertEq(checks[i], expected[i]);
        }
    }
}
