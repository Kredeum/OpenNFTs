# OpenNFTs

OpenNFTs is a smarcontract library of opiniated components and templates, enabling the creation of various NFTs smarcontracts

_OpenNFTs is heavily inspired by the amazing [OpenZeppelin contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts)_

### Install

Intall with npm : `npm install Kredeum/OpenNFTs`
or forge : `forge install Kredeum/OpenNFTs`

### Components

Components are abstract smartcontracts to be inherited from :

- OpenERC165.sol : [EIP-165 'supportsInterface' standard](https://eips.ethereum.org/EIPS/eip-165)
- OpenERC173.sol : [EIP-173 'ownable' standard](https://eips.ethereum.org/EIPS/eip-173)
  &nbsp;
- OpenERC721.sol : [EIP-721 'NFT' standard](https://eips.ethereum.org/EIPS/eip-721)
- OpenERC721TokenReceiver.sol : EIP-721 TokenReceiver option
- OpenERC721Enumerable.sol : EIP-721 Enumerable option
- OpenERC721Metadata.sol : : EIP-721 Metadata option
  &nbsp;
- OpenERC2981.sol : [EIP-2981 'NFT Royalty' standard](https://eips.ethereum.org/EIPS/eip-2981)
- OpenMarketable.sol : AutoMarket component, to sell your NFT at a defined price with royalties (conformant to EIP-2981}, with no need of a centralized MarketPlace
  &nbsp;
- OpenCloneable.sol : Cloneable extension, to be used with EIP-1167 "Minimal Proxy" (available via [NFTsFactoryV2 smartcontract](https://github.com/Kredeum/kredeum/blob/integ/hardhat/contracts/NFTsFactoryV2.sol))
- OpenPauseable.sol : Pausable extension, obviously allows to pause smartcontract

### Templates

Smartcontracts templates using components

- OpenNFTsV4 : latest version of _Kredeum NFTs factory_ default collection

- OpenBound : SoulBound NFTs (i.e. non transferable) that are also multichain: mint it on one chain, claim it on another one.

### Tests

A full set of solidity 'forge' tests are available to test components and templates, to run them :
`forge test`

Moreover, those tests are very generic and enable you to test whatever NFTs smartcontracts, with few added test code.

These tests are also a good example of how to implement a new OpenNFTs template.

### Misc

**This is still beta software, and has not been audited yet, so use at your own risks.**

OpenNFTs is mainly used by [Kredeum NFTs Factory](https://github.com/Kredeum/kredeum) project

If you are a solidity developper, you will be able to develop your own customized OpenNFTs smartcontract and, with the help of Kredeum [NFTsFactoryV2 smartcontract](https://github.com/Kredeum/kredeum/blob/integ/hardhat/contracts/NFTsFactoryV2.sol), to deploy it once then clone it many times.

You can also use [Kredeum NFTs Dapp](https://beta.kredeum.com) to create collection without any coding (only OpenNFTsV3 template available in th UI currently).

We are welcoming any help via PR to develop new templates (and components) in order to support whatever NFTs use case.
