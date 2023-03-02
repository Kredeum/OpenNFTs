#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ]
then

  echo "run from project root dir : "
  echo "certora/run/VacuityCheck.sh"

else

  set -x

  certoraRun                                                        \
  contracts/examples/OpenAutoMarketExHarness.sol                    \
  --verify OpenAutoMarketExHarness:certora/specs/VacuityCheck.spec  \
  --packages OpenNFTs/contracts=contracts                           \
  --msg "OpenAutoMarketExHarness VacuityCheck"                      \
  --optimistic_loop                                                 \
  --rule_sanity                                                     \
  --send_only                                                       \
  $@
  # --typecheck_only                                                  \

fi
