using Receiver as receiver

methods {
  owner             ()                              returns address   envfree
  getEthBalance     (address)                       returns uint256   envfree

  sendTo            ()                              returns bool      envfree => DISPATCHER(true)
  onERC721Received  (address,address,uint256,bytes) returns bytes4    envfree => DISPATCHER(true)
}


/**
* No ETH stored inside NFT collection
*/
rule noETH(method f, env e, calldataarg args){
  require getEthBalance(currentContract) == 0;

  f(e, args);

  assert  getEthBalance(currentContract) == 0;
}
