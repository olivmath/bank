// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IDiamondLoupe} from "./interfaces/ILoupe.sol";
import {Facet} from "./interfaces/Facet.sol";
import {DiamondStorageLib} from "./Lib.sol";

contract DiamondLoupe is IDiamondLoupe {
    using DiamondStorageLib for DiamondStorageLib.Storage;

    function facetAddress(bytes4 fnSelector) external view override returns (address facetAddress_) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        facetAddress_ = ds.fnSelectorToFacet[fnSelector];
    }

    function facetFunctionSelectors(address facet_) external view override returns (bytes4[] memory fnSelectors) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        fnSelectors = new bytes4[](ds.fnSelectorLength);
        uint256 index = 0;
        //
        //
        for (uint256 i = 0; i < ds.fnSelectorLength; i++) {
            if (ds.fnSelectorToFacet[ds.allFnSelectors[i]] == facet_) {
                fnSelectors[index++] = ds.allFnSelectors[i];
                index += 1;
            }
        }
        //
        //
        assembly {
            mstore(fnSelectors, index)
        }
    }

    function facetAddresses() public view override returns (address[] memory facetAddresses_) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        address[] memory uniqueFacetAddresses = new address[](
            ds.fnSelectorLength
        );
        //
        //
        uint256 count = 0;
        for (uint256 i = 0; i < ds.fnSelectorLength; i++) {
            address facetAddress_ = ds.fnSelectorToFacet[ds.allFnSelectors[i]];
            bool isUnique = true;
            for (uint256 j = 0; j < count; j++) {
                if (uniqueFacetAddresses[j] == facetAddress_) {
                    isUnique = false;
                    break;
                }
            }
            //
            //
            if (isUnique) {
                uniqueFacetAddresses[count] = facetAddress_;
                count += 1;
            }
        }
        //
        //
        for (uint256 i = 0; i < count; i++) {
            facetAddresses_[i] = uniqueFacetAddresses[i];
        }
    }

    function facets() external view override returns (Facet[] memory facets_) {
        DiamondStorageLib.Storage storage ds = DiamondStorageLib.getDiamondStorage();
        address[] memory uniqueFacetAddresses = facetAddresses();
        facets_ = new Facet[](uniqueFacetAddresses.length);
        //
        //
        for (uint256 i = 0; i < uniqueFacetAddresses.length; i++) {
            //
            //
            uint256 selectorCount = 0;
            for (uint256 j = 0; j < ds.fnSelectorLength; j++) {
                if (ds.fnSelectorToFacet[ds.allFnSelectors[j]] == uniqueFacetAddresses[i]) {
                    selectorCount += 1;
                }
            }
            //
            //
            bytes4[] memory fnSelectors = new bytes4[](selectorCount);
            uint256 index = 0;
            for (uint256 j = 0; j < ds.fnSelectorLength; j++) {
                if (ds.fnSelectorToFacet[ds.allFnSelectors[j]] == uniqueFacetAddresses[i]) {
                    fnSelectors[index] = ds.allFnSelectors[j];
                    index += 1;
                }
            }
            //
            //
            facets_[i] = Facet(uniqueFacetAddresses[i], fnSelectors);
        }
    }
}
