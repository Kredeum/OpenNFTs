methods {
  function owner              ()                external returns address   envfree;
  function getTreasury        ()                external returns address   envfree;
  function getRoyaltyReceiver (uint256)         external returns address   envfree;
  function getRoyaltyAmount   (uint256,uint256) external returns uint256   envfree;
  function sum4               (address,address,address,address) external returns uint256  envfree;

  function getTokenPrice      (uint256)         external returns uint256   envfree;
  function ownerOf            (uint256)         external returns address   envfree;
  function buy                (uint256)         external                          ;
  function withdraw           ()                external returns uint256          ;

  function _.sendTo           ()                                external  => DISPATCHER(true);
  function _.onERC721Received  (address,address,uint256,bytes)  external  => DISPATCHER(true);
}

definition MAX_ETHER() returns uint256 = 2^100;



rule buyOnlyBalBuyerDecrease(env e, uint256 tokenID, address random) {
  address buyer = e.msg.sender;

  uint256 _balRandom = nativeBalances[random];
  buy(e, tokenID);
  uint256 balRandom_ = nativeBalances[random];

  assert  balRandom_ < _balRandom => random == buyer;
}

rule buyOnlyBalSellerOrTreasuryOrReceiverIncrease(env e, uint256 tokenID, address random) {
  address seller   = ownerOf(tokenID);
  address receiver = getRoyaltyReceiver(tokenID);
  address treasury = getTreasury();

  uint256 _balRandom = nativeBalances[random];
  buy(e, tokenID);
  uint256 balRandom_ = nativeBalances[random];

  assert  balRandom_ > _balRandom =>
          random == seller || random == receiver || random == treasury;
}

rule buyBuyerBecomesOwner(env e, uint256 tokenID) {
  address buyer = e.msg.sender;

  buy(e, tokenID);

  assert ownerOf(tokenID) == buyer;
}

rule buySumOfBalsUnChanged(env e, uint256 tokenID) {
  address buyer = e.msg.sender;
  address seller = ownerOf(tokenID);
  address royalty = getRoyaltyReceiver(tokenID);
  address treasury = getTreasury();

  mathint _sum = sum4(buyer, seller, royalty, treasury);
  buy(e, tokenID);
  mathint sum_ = sum4(buyer, seller, royalty, treasury);

  assert  sum_ == _sum;
}