methods {
    getEthBalance(address) envfree
    ownerOf(uint256) envfree
    buy(uint256)  
}

rule noMoneyLost() {
    env e; uint256 tokenID;
   
    uint256 balBuyerBefore = getEthBalance(e.msg.sender);

    require ownerOf(tokenID) != e.msg.sender;
    buy(e, tokenID);
    require ownerOf(tokenID) == e.msg.sender;

    assert getEthBalance(e.msg.sender) <= balBuyerBefore;
}
