// SPDX-License-Identifier: MITs
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "OpenNFTs/contracts/interfaces/IERC165.sol";
import "OpenNFTs/contracts/interfaces/IERC721.sol";
import "OpenNFTs/contracts/interfaces/IERC721Events.sol";

contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}

contract ERC721TokenReceiverNot {
    function onERC721Received(address, address, uint256, bytes calldata)
        external
        pure
        returns (bytes4)
    {
        return 0x0;
    }
}

abstract contract ERC721TransferableTest is Test, IERC721Events {
    address private _collection;
    string private _tokenURI;
    address private _owner = address(0x1001);
    address private _minter = address(0x1002);
    address private _buyer = address(0x1003);
    address private _tester = address(0x1004);
    uint256 private _tokenID0;

    function constructorTest(address owner_) public virtual returns (address);

    function mintTest(address collection_, address minter_)
        public
        virtual
        returns (uint256, string memory);

    function setUpERC721Transferable() public {
        _collection = constructorTest(_owner);

        (_tokenID0,) = mintTest(_collection, _minter);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _minter);
    }

    function testERC721SafeTransferFrom() public {
        changePrank(_minter);

        IERC721(_collection).safeTransferFrom(_minter, _tester, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _tester);
    }

    function testERC721SafeTransferFromWithData() public {
        changePrank(_minter);

        IERC721(_collection).safeTransferFrom(_minter, _tester, _tokenID0, "data");
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _tester);
    }

    function testERC721SafeTransferFromEmit() public {
        changePrank(_minter);

        vm.expectEmit(true, true, true, false);
        emit Transfer(_minter, _tester, _tokenID0);
        IERC721(_collection).safeTransferFrom(_minter, _tester, _tokenID0);
    }

    function testERC721SafeTransferFromWithDataEmit() public {
        changePrank(_minter);

        vm.expectEmit(true, true, true, false);
        emit Transfer(_minter, _tester, _tokenID0);
        IERC721(_collection).safeTransferFrom(_minter, _tester, _tokenID0, "data");
    }

    function testERC721SafeTransferFromEOAFuzzy(address from, address to) public {
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        vm.assume(to != from);
        vm.assume(from.code.length == 0);
        vm.assume(to.code.length == 0);

        (uint256 tokenID,) = mintTest(_collection, from);

        vm.expectEmit(true, true, true, false);
        emit Transfer(from, to, tokenID);
        IERC721(_collection).safeTransferFrom(from, to, tokenID);
        assertEq(IERC721(_collection).ownerOf(tokenID), to);
    }

    function testERC721TransferFrom() public {
        changePrank(_minter);

        IERC721(_collection).transferFrom(_minter, _tester, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _tester);
    }

    function testERC721TransferFromEOAFuzzy(address from, address to) public {
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        vm.assume(from.code.length == 0);
        vm.assume(to.code.length == 0);

        (uint256 tokenID,) = mintTest(_collection, from);

        vm.expectEmit(true, true, true, false);
        emit Transfer(from, to, tokenID);
        IERC721(_collection).transferFrom(from, to, tokenID);
        assertEq(IERC721(_collection).ownerOf(tokenID), to);
    }

    function testERC721transferFromToThisContract() public {
        changePrank(_minter);

        IERC721(_collection).transferFrom(_minter, address(this), _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), address(this));
    }

    function testFailERC721SafeTransferFromToNotReceiverContract() public {
        changePrank(_minter);

        IERC721(_collection).safeTransferFrom(_minter, address(this), _tokenID0);
    }

    function testERC721TransferFromToReceiverContract() public {
        address receiverContract = address(new ERC721TokenReceiver());

        changePrank(_minter);
        IERC721(_collection).transferFrom(_minter, receiverContract, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), receiverContract);
    }

    function testERC721SafeTransferFromToReceiverContract() public {
        address receiverContract = address(new ERC721TokenReceiver());

        changePrank(_minter);

        IERC721(_collection).safeTransferFrom(_minter, receiverContract, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), receiverContract);
    }

    function testERC721TransferFromToNotReceiverContract() public {
        changePrank(_minter);
        address receiverContractNot = address(new ERC721TokenReceiverNot());

        IERC721(_collection).transferFrom(_minter, receiverContractNot, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), receiverContractNot);
    }

    function testERC721SafeTransferFromToNotReceiverContract() public {
        changePrank(_minter);
        address receiverContractNot = address(new ERC721TokenReceiverNot());

        vm.expectRevert("Not ERC721Receiver");
        IERC721(_collection).safeTransferFrom(_minter, receiverContractNot, _tokenID0);
    }

    function testERC721Approve() public {
        changePrank(_minter);
        vm.expectEmit(true, true, true, false);
        emit Approval(_minter, _tester, _tokenID0);
        IERC721(_collection).approve(_tester, _tokenID0);

        changePrank(_tester);
        IERC721(_collection).safeTransferFrom(_minter, _buyer, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _buyer);
    }

    function testERC721SetApprovalForAll() public {
        changePrank(_minter);
        vm.expectEmit(true, true, true, false);
        emit ApprovalForAll(_minter, _tester, true);
        IERC721(_collection).setApprovalForAll(_tester, true);

        changePrank(_tester);
        IERC721(_collection).safeTransferFrom(_minter, _buyer, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _buyer);
    }

    function testFailERC721TransferFromToZeroAddress() public {
        changePrank(_minter);
        IERC721(_collection).safeTransferFrom(_minter, address(0), _tokenID0);
    }

    function testFailERC721TransferFromFromZeroAddress() public {
        changePrank(_minter);
        IERC721(_collection).safeTransferFrom(address(0), _tester, _tokenID0);
    }

    function testERC721TransferFromToSameAddress() public {
        changePrank(_minter);
        IERC721(_collection).safeTransferFrom(_minter, _tester, _tokenID0);
        assertEq(IERC721(_collection).ownerOf(_tokenID0), _tester);
    }
}
