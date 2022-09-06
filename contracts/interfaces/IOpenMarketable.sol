// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IOpenMarketable {
    event SetDefaultRoyalty(address receiver, uint96 fee);

    event SetTokenRoyalty(uint256 tokenID, address receiver, uint96 fee);

    event SetDefaultPrice(uint256 price);

    event SetTokenPrice(uint256 tokenID, uint256 price);

    event Pay(
        uint256 tokenID,
        uint256 price,
        address seller,
        uint256 paid,
        address receiver,
        uint256 royalties,
        address buyer,
        uint256 unspent
    );

    receive() external payable;

    function setDefaultRoyalty(address receiver, uint96 fee) external;

    function setTokenRoyalty(uint256 tokenID, address receiver, uint96 fee) external;

    function setTokenRoyaltyReceiver(uint256 tokenID, address receiver) external;

    function setDefaultPrice(uint256 price) external;

    function setTokenPrice(uint256 tokenID, uint256 price) external;

    function defaultPrice() external view returns (uint256 defPrice);

    function tokenPrice(uint256 tokenID) external view returns (uint256 price);

    function getDefaultRoyalty() external view returns (address receiver, uint96 fee);

    function getTokenRoyalty(uint256 tokenID) external view returns (address receiver, uint96 fee);
}
