methods {
    getEthBalance(address) envfree
    transferValue(address)
}

rule transferOk() {
    env e; address to; uint256 value;

    uint256 balFromBefore = getEthBalance(e.msg.sender);
    uint256 sent = transferValue(e, to, value);
    uint256 balFromAfter = getEthBalance(e.msg.sender);

    assert balFromAfter <= balFromBefore;
}
