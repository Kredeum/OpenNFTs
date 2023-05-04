```
      ___           ___         ___           ___
     /  /\         /  /\       /  /\         /__/\
    /  /::\       /  /::\     /  /:/_        \  \:\
   /  /:/\:\     /  /:/\:\   /  /:/ /\        \  \:\
  /  /:/  \:\   /  /:/~/:/  /  /:/ /:/_   _____\__\:\
 /__/:/ \__\:\ /__/:/ /:/  /__/:/ /:/ /\ /__/::::::::\
 \  \:\ /  /:/ \  \:\/:/   \  \:\/:/ /:/ \  \:\~~\~~\/
  \  \:\  /:/   \  \::/     \  \::/ /:/   \  \:\  ~~~
   \  \:\/:/     \  \:\      \  \:\/:/     \  \:\
    \  \::/       \  \:\      \  \::/       \  \:\
     \__\/         \__\/       \__\/         \__\/
      ___           ___                     ___
     /__/\         /  /\        ___        /  /\
     \  \:\       /  /:/_      /  /\      /  /:/_
      \  \:\     /  /:/ /\    /  /:/     /  /:/ /\
  _____\__\:\   /  /:/ /:/   /  /:/     /  /:/ /::\
 /__/::::::::\ /__/:/ /:/   /  /::\    /__/:/ /:/\:\
 \  \:\~~\~~\/ \  \:\/:/   /__/:/\:\   \  \:\/:/~/:/
  \  \:\  ~~~   \  \::/    \__\/  \:\   \  \::/ /:/
   \  \:\        \  \:\         \  \:\   \__\/ /:/
    \  \:\        \  \:\         \__\/     /__/:/
     \__\/         \__\/                   \__\/

```

# OpenNFTs

*OpenNFTs is the NFT lego* : a library of smarcontract components, enabling the development of numerous NFT Collections


The general architeture of this library is mainly visible via the inheritance graph of the main OpenNFTs component:

```
//
//   OpenERC165
//   (supports)
//       |
//       ——————————————————————————————————————————————————————————————————————
//       |                                       |             |              |
//   OpenERC721                            OpenERC2981    OpenERC173    OpenCloneable
//     (NFT)                              (RoyaltyInfo)    (ownable)          |
//       |                                        |            |              |
//       ——————————————————————————————————————   |     ————————              |
//       |                        |           |   |     |      |              |
//  OpenERC721Metadata  OpenERC721Enumerable  |   ———————      |              |
//       |                        |           |   |            |              |
//       |                        |      OpenMarketable   OpenPauseable       |
//       |                        |             |              |              |
//       ——————————————————————————————————————————————————————————————————————
//       |
//    OpenNFTs —— IOpenNFTs
//
```

_These components have been initially created by the [Kredeum NFTs](https://github.com/Kredeum/kredeum) project_

### Install

Install with npm :

`npm install Kredeum/OpenNFTs`

or forge :

`forge install Kredeum/OpenNFTs`

### Components

Components are abstracted smartcontracts to be inherited from :

#### OpenERC
OpenERC extension pack, implementation of some of NFT relative ERCs
-   OpenERC165.sol : [EIP-165 'supportsInterface' standard](https://eips.ethereum.org/EIPS/eip-165)
-   OpenERC173.sol : [EIP-173 'ownable' standard](https://eips.ethereum.org/EIPS/eip-173)
-   OpenERC721.sol : [EIP-721 'NFT' standard](https://eips.ethereum.org/EIPS/eip-721)
-   OpenERC721Enumerable.sol : EIP-721 Enumerable option
-   OpenERC721Metadata.sol : : EIP-721 Metadata option
-   OpenERC721TokenReceiver.sol : EIP-721 TokenReceiver option
-   OpenERC2981.sol : [EIP-2981 'NFT Royalty' standard](https://eips.ethereum.org/EIPS/eip-2981)

#### OpenNFTs
OpenNFTs main pack, to be used by your NFT template
-   OpenGuard.sol : Guard from reentrancy attack
-   OpenMarketable.sol : AutoMarket component, to sell your NFT at a defined price with royalties (conformant to
EIP-2981) with no need of a centralized MarketPlace
-   OpenNFT.sol : Generic NFT components
-   OpenPauseable.sol : Pausable extension, obviously allows to pause smartcontract

#### OpenResolve
OpenResolve extension pack, to read whatever NFTs infos : free, no gas required !
-   OpenChecker.sol : Checkable extension, to check multiple ERC165 extensions
-   OpenGetter.sol : Get infos from whatever NFT Collection and list of minted NFTs
-   OpenRegistry.sol : Register your favorite NFT Collections, to be queried multiple times
-   OpenResolver.sol : Resolve all the infos from a set of Collections

#### OpenClone
OpenClone extension pack, via the use of EIP-1167 "Minimal Proxy"
-   OpenCloner.sol : inherited by factory cloner
-   OpenCloneable.sol : inherited by template smartcontracts to be cloned

### Examples

Here are some smartcontracts given as example on howto "compose" components to make usable NFT Collections:

-   OpenNFTsEx : a generic NFT template

-   OpenAutoMarketEx : a template with AutoMarket

-   OpenResolverEx : a generic Resolver to get NFT infos

-   OpenBoundEx : a multichain SoulBound NFT template

-   OpenClonerEx : a NFTs Factory template

*Be carefull, these templates are not production ready.*

### Tests

A full set of solidity 'forge' tests are available to validate components and templates, to run them :

`forge test`

Those tests are very generic and enable you to test whatever NFTs smartcontracts, with few added code.

### Misc

**This is still beta software, and has not been audited yet, so use at your own risks.**

We are welcoming any help via PR to develop new components. Like, for example,
ERC1155 support or a OpenMuliMintable component (enabling minting of multiple NFTs in a single transaction).

OpenNFTs is not "gas optimized", so deploy it carefully on Ethereum mainnet. That's why it's more dedicated to
templates, to be cloned mutliple times, than for a unique NFT Collection deployment.

*You can also use [Kredeum Dapp](https://beta.kredeum.com) to create NFT Collection without any coding.*


### Acknowledgments

This OpenSource project has been developped with the help of :

-   [ETH Global](https://ethglobal.com/): via various Hackathons and prices
-   [Polygon](https://polygon.technology/funds/): via a grant on the multichain NFT feature
-   [GitCoin and all donators](https://gitcoin.co/grants/4186/kredeum-decentralized-nfts-factory): via Grant Rounds 12 to 15
-   [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts): _OpenNFTs is heavily inspired by the more generic OpenZeppelin contracts_

Thanks to all of them.
