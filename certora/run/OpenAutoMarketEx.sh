#!/bin/bash

if [ $# -le 1 ]
then
  set -x

  certoraRun                                                            \
  certora/src/OpenAutoMarketExHarness.sol                               \
  certora/src/Receiver.sol                                              \
  --verify OpenAutoMarketExHarness:certora/specs/OpenAutoMarketEx.spec  \
	--optimistic_loop                                                     \
  --msg OpenAutoMarketEx                                                \
  --rule_sanity                                                         \
  --packages                                                            \
  OpenNFTs/contracts=contracts                                          \
  $([ $# -ge 1 ] && echo --rule $@)                                     \

else

  echo "run from project root dir : "
  echo "certora/run/OpenAutoMarketEx.sh"

fi