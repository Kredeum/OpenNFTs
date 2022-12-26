methods {
    getEthBalance(address) envfree
    ownerOf(uint256) envfree
    buy(uint256)  
}

rule noMoneyLost() {
    address seller; address buyer; address receiver; address treasury;
    uint256 price;
    uint256 tokenID;
  
    uint256 balSellerBefore = getEthBalance(seller);
    uint256 balBuyerBefore = getEthBalance(buyer);

    env e; calldataarg args; 

    require seller == ownerOf(tokenID);
    buy(e, tokenID);
    require buyer == ownerOf(tokenID);

    uint256 balSellerAfter = getEthBalance(seller);
    uint256 balBuyerAfter = getEthBalance(buyer);

    assert balBuyerAfter <= balBuyerBefore;
}
