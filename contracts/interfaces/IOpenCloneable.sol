// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IOpenCloneable {
    function initialize(bytes memory params) external;

    function initialized() external view returns (bool);

    function template() external view returns (string memory);

    function version() external view returns (uint256);

    function parent() external view returns (address);
}
