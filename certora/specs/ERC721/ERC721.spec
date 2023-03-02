methods {
    balanceOf(address)                                  returns (uint256)   envfree
    ownerOf(uint256)                                    returns (address)   envfree
    safeTransferFrom(address,address,uint256,bytes) 
    safeTransferFrom(address,address,uint256) 
    transferFrom(address,address,uint256) 
    approve(address,uint256)
    setApprovalForAll(address,bool)
    getApproved(uint256)                                returns (address)   envfree
    isApprovedForAll(address,  address)                 returns (bool)      envfree
    supportsInterface(bytes4)                           returns (bool)      envfree
}
