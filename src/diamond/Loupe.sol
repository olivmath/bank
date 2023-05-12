// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IDiamondLoupe} from "./interfaces/ILoupe.sol";
import {Facet} from "./interfaces/Facet.types.sol";
import {DiamondStorageLib} from "./Lib.sol";

contract DiamondLoupe is IDiamondLoupe {
    using DiamondStorageLib for DiamondStorageLib.Storage;

    function facetAddress(bytes4 fnSelector) external view override returns (address facetAddress_) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        facetAddress_ = ds.fnSelectorToFacet[fnSelector].facet;
    }

    function facetFunctionSelectors(address facet_) external view override returns (bytes4[] memory fnSelectors) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        fnSelectors = ds.facetToFnSelectors[facet_].fnSelectors;
    }

    function facetAddresses() external view override returns (address[] memory facetAddresses_) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        facetAddresses_ = ds.facets;
    }

    function facets() external view override returns (Facet[] memory facets_) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();

        uint256 numFacets = ds.facetsLength;
        facets_ = new Facet[](numFacets);

        for (uint256 i; i < numFacets; i++) {
            address facetAddress_ = ds.facets[i];
            facets_[i].facetAddress = facetAddress_;
            facets_[i].fnSelectors = ds.facetToFnSelectors[facetAddress_].fnSelectors;
        }
    }
}
