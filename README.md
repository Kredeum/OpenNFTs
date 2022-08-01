# OpenNFTs

OpenNFTs is a library of smarcontract components, enabling the creation of various NFT Collection smartcontracts, mainly
clonable templates

Generic inheritance graph:

```
 OpenERC165
 (supports)
     |
     ———————————————————————————————————————————————————————————————————————————————————
     |                                       |             |             |             |
 OpenERC721                            OpenERC2981    OpenERC173  OpenCheckable  OpenCloneable
   (NFT)                              (RoyaltyInfo)    (ownable)         |             |
     |                                        |            |             |             |
     ——————————————————————————————————————   |     ————————             |             |
     |                        |           |   |     |      |             |             |
OpenERC721Metadata  OpenERC721Enumerable  |   ———————      |             |             |
     |                        |           |   |            |             |             |
     |                        |      OpenMarketable   OpenPauseable      |             |
     |                        |             |              |             |             |
     ———————————————————————————————————————————————————————————————————————————————————
     |
  OpenNFTs
```

_These components have been initially created by the [Kredeum NFTs Factory](https://github.com/Kredeum/kredeum) project_

### Install

Install with npm :

`npm install Kredeum/OpenNFTs`

or forge :

`forge install Kredeum/OpenNFTs`

### Components

Components are abstracted smartcontracts to be inherited from :

-   OpenERC165.sol : [EIP-165 'supportsInterface' standard](https://eips.ethereum.org/EIPS/eip-165)
-   OpenERC173.sol : [EIP-173 'ownable' standard](https://eips.ethereum.org/EIPS/eip-173)
<!-- -->
-   OpenERC721.sol : [EIP-721 'NFT' standard](https://eips.ethereum.org/EIPS/eip-721)
-   OpenERC721TokenReceiver.sol : EIP-721 TokenReceiver option
-   OpenERC721Enumerable.sol : EIP-721 Enumerable option
-   OpenERC721Metadata.sol : : EIP-721 Metadata option
<!-- -->
-   OpenERC2981.sol : [EIP-2981 'NFT Royalty' standard](https://eips.ethereum.org/EIPS/eip-2981)
-   OpenMarketable.sol : AutoMarket component, to sell your NFT at a defined price with royalties (conformant to
EIP-2981) with no need of a centralized MarketPlace
<!-- -->
-   OpenCloneable.sol : Cloneable extension, to be used with EIP-1167 "Minimal Proxy" (available via
    [NFTsFactoryV2 smartcontract](https://github.com/Kredeum/kredeum/blob/integ/hardhat/contracts/NFTsFactoryV2.sol))
-   OpenPauseable.sol : Pausable extension, obviously allows to pause smartcontract
-   OpenCheckable.sol : Checkable extension, to check multiple ERC165 extensions in a single static call

### Templates

Here are some smartcontracts given as example on howto "compose" components to make a usable NFT Collection
smartcontract:

-   OpenNFTsEx : a generic template with automarket

-   OpenBoundEx : a multichain SoulBound NFTs

Be carefull, these templates are not production ready. Go to Kredeum NFTs Factory to get production version of these 2
templates.

### Tests

A full set of solidity 'forge' tests are available to validate components and templates, to run them :

`forge test`

Moreover, those tests are very generic and enable you to test whatever NFTs smartcontracts, with few added test code.
Also a good example of how to implement a new OpenNFTs template.

### Misc

**This is still beta software, and has not been audited yet, so use at your own risks.**

If you are a solidity developper, you will be able to develop your own customized OpenNFTs template and, with the help
of
[Kredeum NFTsFactoryV2 smartcontract](https://github.com/Kredeum/kredeum/blob/integ/hardhat/contracts/NFTsFactoryV2.sol),
to deploy it once then clone it many times.

You can also use [Kredeum NFTs Dapp](https://beta.kredeum.com) to create NFT Collection without any coding (only
OpenNFTsV3 template available in current UI).

We are welcoming any help via PR to develop new components in order to support whatever NFT use cases. Like for example
ERC1155 suppor or a OpenMuliMintable component, enabling minting of multiple NFTs in a single transaction.

OpenNFTs is not "gas optimized", so deploy it carefully on Ethereum mainnet. That's why it's more dedicated to
templates, to be cloned mutliple times, than for a unique NFT Collection deployment. With the Kredeum NFTs Factory, only
first deploy costs lot of gas, afterwards clone deployment is much cheaper.

### Acknowledgments

This OpenSource project has been developped with the help of :

-   [ETH Global](https://ethglobal.com/): via various Hackathons and prices
-   [Polygon](https://polygon.technology/funds/): via a grant on the multichain NFT feature
-   [GitCoin and all donators](https://gitcoin.co/grants/4186/kredeum-decentralized-nfts-factory): via Grant Rounds 12,
    13 and 14
-   [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts): _OpenNFTs is heavily
    inspired by the more generic OpenZeppelin contracts_

Thanks to all of them.
