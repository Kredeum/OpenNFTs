
e#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ]
then

  echo "run from project root dir : "
  echo "certora/run/Buy.sh"

else

  set -x

  certoraRun                                                  \
  contracts/examples/OpenAutoMarketExHarness.sol              \
  contracts/OpenERC/OpenERC721TokenReceiver.sol               \
  --verify OpenAutoMarketExHarness:certora/specs/Buy.spec     \
  --rule_sanity                                               \
  --send_only                                                 \
  --msg "OpenAutoMarketExHarness Buy"                         \
  --packages OpenNFTs/contracts=contracts                     \
  --multi_assert_check                                        \
  $@
  # --typecheck_only                                                  \
  # --optimistic_loop                                                 \

fi
