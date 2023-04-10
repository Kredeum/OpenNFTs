// SPDX-License-Identifier: MIT
//   OpenGuard
//
pragma solidity ^0.8.19;

abstract contract OpenGuard {
  bool private _locked;

  modifier reEntryGuard() {
    require(!_locked, "No re-entry!");

    _locked = true;

    _;

    _locked = false;
  }
}
