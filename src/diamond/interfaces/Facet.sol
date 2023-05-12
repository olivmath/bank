// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct Facet {
    address facetAddress;
    bytes4[] functionSelectors;
}
