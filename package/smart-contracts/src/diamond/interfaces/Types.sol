// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

error InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);
error CannotAddFunctionToDiamondThatAlreadyExists(bytes4 _selector);
error FacetZeroAddress(address facetAddress, string debugMessage);
error NoBytecodeAtAddress(address _contract, string debugMessage);
error CannotRemoveImmutableFunction(address facetAddress);
error FunctionNotFound(bytes4 fnSelector);
error IncorrectAction(uint8 action);
error FnSelectorsEmpty();

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
