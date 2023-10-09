// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OpenERC165} from "contracts/OpenERC/OpenERC165.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IERC721} from "contracts/interfaces/IERC721.sol";
import {IERC6551Account} from "contracts/interfaces/IERC6551Account.sol";
import {IERC6551Executable} from "contracts/interfaces/IERC6551Executable.sol";

// import {console} from "forge-std/console.sol";

contract OpenTBA is IERC6551Account, IERC6551Executable, OpenERC165 {
  using Address for address;

  // bytes32(uint256(keccak256(eip6551.state")) - 1));
  bytes32 private constant _STATE_SLOT =
    0x6f941490d2819c2355cdebcdde9a60879d6d1c985ea58dd227c467fcb99feb3c;

  receive() external payable override(IERC6551Account) {}

  function execute(address to, uint256 value, bytes calldata data, uint256 operation)
    public
    payable
    override(IERC6551Executable)
    returns (bytes memory result)
  {
    require(_isValidSigner(msg.sender), "Invalid signer");
    require(operation <= 1, "Create operations not supported");

    // CALL
    if (operation == 0) {
      result = to.functionCallWithValue(data, value);
    }

    // DELEGATECALL
    if (operation == 1) {
      uint256 stateBefore = state();

      result = to.functionDelegateCall(data);

      uint256 stateAfter = state();

      require(stateAfter == stateBefore, "Must not change state");
    }

    _incrementState();
  }

  function state() public view override(IERC6551Account) returns (uint256) {
    return StorageSlot.getUint256Slot(_STATE_SLOT).value;
  }

  function isValidSigner(address signer, bytes calldata)
    public
    view
    override(IERC6551Account)
    returns (bytes4)
  {
    if (_isValidSigner(signer)) {
      return IERC6551Account.isValidSigner.selector;
    }

    return bytes4(0);
  }

  function supportsInterface(bytes4 interfaceId) public view override(OpenERC165) returns (bool) {
    return (
      interfaceId == 0x6faff5f1 // = type(IERC6551Account).interfaceId
        || interfaceId == 0x74420f4c // = type(IERC6551Executable).interfaceId
        || super.supportsInterface(interfaceId)
    );
  }

  function token() public view override(IERC6551Account) returns (uint256, address, uint256) {
    bytes memory footer = new bytes(0x60);

    assembly {
      extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
    }

    return abi.decode(footer, (uint256, address, uint256));
  }

  function _incrementState() internal {
    StorageSlot.getUint256Slot(_STATE_SLOT).value += 1;
  }

  function _isValidSigner(address signer) internal view returns (bool) {
    return signer == owner();
  }

  function owner() public view returns (address) {
    (uint256 chainId, address tokenContract, uint256 tokenId) = token();
    if (chainId != block.chainid) return address(0);

    return IERC721(tokenContract).ownerOf(tokenId);
  }
}
