// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "forge-std/Test.sol";

interface IPayable {
    receive() external payable;

    function getNum() external view returns (uint256);
}

contract Payable is IPayable {
    uint256 private _num = 42;

    receive() external payable override(IPayable) {}

    function getNum() external view override(IPayable) returns (uint256) {
        return _num;
    }
}

contract PayableTest is Test {
    Payable private _payable;
    address payable _payableAddress;

    function setUp() public {
        _payable = new Payable();
        _payableAddress = payable(address(_payable));
    }

    function test101() external {
        assertEq(_payable.getNum(), 42);
    }

    function test102() external view {
        console.log(IPayable(_payableAddress).getNum());
    }
}
