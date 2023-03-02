import "ERC721/ERC721.spec"
methods {
    onERC721Received(address,address,uint256,bytes)     returns(bytes4) => DISPATCHER(true)

    getEthBalance(address)                                                 envfree
    getTokenPrice(uint256)                              returns (uint256)   envfree
    mint(string)                                        returns (uint256)
    buy(uint256)  
    setTokenPrice(uint256,uint256)
}

definition globalInvariant(env e) returns bool =
  e.msg.sender != 0;

rule mintRule() {
	env e; calldataarg args;

    uint256 tokenID = mint(e, args);
    
    assert ownerOf(tokenID) == e.msg.sender;
    assert tokenID >= 1;
}

rule setTokenPriceRule() {
	env e;
    uint256 tokenID;
    uint256 price;
    
    setTokenPrice(e, tokenID, price);

    address owner = ownerOf(tokenID);
    assert getTokenPrice(tokenID) == price;
    assert  
        owner == e.msg.sender                  || 
        getApproved(tokenID) == e.msg.sender  ||
        isApprovedForAll(owner, e.msg.sender) ;
}

rule buyRule() {
	env e0;
    uint256 price;
    uint256 tokenID;

    require price > 0;
    require e0.msg.sender == ownerOf(tokenID);
    
    setTokenPrice(e0, tokenID, price);
    approve(e0, currentContract, tokenID);

    env e1; 
    require e1.msg.sender != e0.msg.sender;
    require e1.msg.value >= price;

    buy@withrevert(e1, tokenID);
    assert e1.msg.sender == ownerOf(tokenID);
}

rule noMoneyLost() {
    env e0;
    require e0.msg.sender != currentContract;
    uint256 tokenID = mint(e0, "Test");
    uint256 price = 1;
    setTokenPrice(e0, tokenID, price);
    approve(e0, currentContract, tokenID);

    env e1; 
    require e1.msg.sender != e0.msg.sender;
    require e1.msg.value >= price;

    uint256 balBuyerBefore = getEthBalance(e1.msg.sender);  
    uint256 balSellerBefore = getEthBalance(currentContract);
    require e1.msg.sender != ownerOf(tokenID);
    buy@withrevert(e1, tokenID);
    assert e1.msg.sender == ownerOf(tokenID);

    uint256 balBuyerAfter = getEthBalance(e1.msg.sender);
    uint256 balSellerAfter = getEthBalance(currentContract);

    assert balBuyerBefore + balSellerBefore == balBuyerAfter + balSellerAfter;
    assert balSellerAfter == balSellerBefore + e1.msg.value;
    assert balBuyerBefore == balBuyerAfter + e1.msg.value;
    assert balBuyerBefore >= balBuyerAfter;
}
