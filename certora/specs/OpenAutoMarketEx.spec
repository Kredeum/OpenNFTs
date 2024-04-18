using Receiver as receiver;

methods {
  function owner             ()                                 external returns address   envfree;
  function getEthBalance     (address)                          external returns uint256   envfree;
  function getTreasury       ()                                 external returns address   envfree;
  function getReceiver       (uint256)                          external returns address   envfree;

  function getTokenPrice     (uint256)                          external returns uint256   envfree;
  function ownerOf           (uint256)                          external returns address   envfree;
  function buy               (uint256)                          external                          ;
  function withdraw          ()                                 external returns uint256          ;

  function _.sendTo            ()                               external                          ;
  function _.onERC721Received  (address,address,uint256,bytes)  external                          ;
}

/**
* No ETH balance change in NFT collection (except withdraw)
* Only buyer or collection may have ETH balance decreased
* Only buy, withdraw and transfer functions may change some ETH balances
*/
rule balChanges(method f, env e, calldataarg args){
  address random;
  require e.msg.sender != currentContract;

  mathint balRandomBefore = getEthBalance(random);
  f(e, args);
  mathint balRandomAfter = getEthBalance(random);

  // Bad rule: certora formal verification doesn't properly check ETH balances
  // foundry counter example in OpenAutoMarketExHackTest.sol
  // if buyer can't receive ether, unspent ETH is stuck in contract...
  // No ETH balance change in NFT collection (except withdraw)
  assert ( random == currentContract ) &&  ( f.selector != sig:withdraw().selector )
    =>  balRandomAfter == balRandomBefore;

  // Only buyer (i.e. sender) or collection (on withdraw) may have ETH balance decreased
  assert balRandomAfter < balRandomBefore
    =>  random == e.msg.sender
    ||  ( ( random == currentContract ) && ( f.selector == sig:withdraw().selector ) );

  // Only buy, withdraw and transfer functions may change some ETH balances
  assert balRandomAfter != balRandomBefore =>
       f.selector == sig:buy(uint256).selector
    || f.selector == sig:withdraw().selector
    || f.selector == sig:transferFrom(address,address,uint256).selector
    || f.selector == sig:safeTransferFrom(address,address,uint256).selector
    || f.selector == sig:safeTransferFrom(address,address,uint256,bytes).selector;
}

/**
* Check balance change on buy
*/
rule balChangesInBuy() {
  env e; uint256 tokenID;

  address buyer = e.msg.sender;
  address seller = ownerOf(tokenID);
  address royalty = getReceiver(tokenID);
  address treasury = getTreasury();
  address random;
  require random != buyer && random != seller && random != receiver && random != treasury;

  mathint balBuyerBefore    = getEthBalance(buyer);
  mathint balSellerBefore   = getEthBalance(seller);
  mathint balRoyaltyBefore  = getEthBalance(royalty);
  mathint balTreasuryBefore = getEthBalance(treasury);
  mathint balRandomBefore   = getEthBalance(random);
  mathint price             = getTokenPrice(tokenID);

  buy(e, tokenID);
  assert buyer == ownerOf(tokenID);

  mathint balBuyerAfter    = getEthBalance(buyer);
  mathint balSellerAfter   = getEthBalance(seller);
  mathint balRoyaltyAfter  = getEthBalance(royalty);
  mathint balTreasuryAfter = getEthBalance(treasury);
  mathint balRandomAfter   = getEthBalance(random);

  // If price is 0 all bal unchanged
  assert price == 0
    =>  balRandomAfter == balRandomBefore;

  // Buyer bal can only decrease
  assert balBuyerAfter     <= balBuyerBefore;

  // Seller bal can only increase
  assert balSellerAfter    >= balSellerBefore;

  // Royalty receiver bal can only increase
  assert balRoyaltyAfter   >= balRoyaltyBefore;

  // Treasury bal can only increase
  assert balTreasuryAfter  >= balTreasuryBefore;

  // Sum of balances unchanged beetwen buyer, seller, receiver and treasury
  assert balBuyerAfter  + balSellerAfter  + balRoyaltyAfter  + balTreasuryAfter
    ==  balBuyerBefore + balSellerBefore + balRoyaltyBefore + balTreasuryBefore;

  // Random wallet bal is unchanged
  assert random != buyer && random != seller && random != receiver && random != treasury
    => balRandomAfter == balRandomBefore;

  // If price is > 0 , and buyer != seller then seller bal strictly increase
  assert ( price  > 0 ) && ( buyer != seller )
    =>  balSellerAfter > balSellerBefore;

  // Buyer bal decrease exactly by price (if not seller, receiver or treasury)
  assert buyer != seller && buyer != receiver && buyer != treasury
    =>  balBuyerAfter == balBuyerBefore - price;
}
