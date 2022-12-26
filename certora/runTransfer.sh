cd ..

CERTORA_COMMAND="certoraRun                   \
contracts/examples/TransferValue.sol          \
--verify TransferValue:certora/transfer.spec  \
$([ $# -ge 1 ] && echo --rule $@)             \
--rule_sanity                                 \
--send_only                                   \
--msg certoraRun_TransferValue                \
--packages OpenNFTs/contracts=contracts       \
"

echo $CERTORA_COMMAND

$CERTORA_COMMAND