// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

enum Action {
    Save,
    Modify,
    Remove
}

struct Facet {
    address facetAddress;
    bytes4[] fnSelectors;
    Action action;
}
