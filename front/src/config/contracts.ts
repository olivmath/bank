import { Address } from "viem";

const BANK_ADDRESS: Address = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";
const DIAMOND_ADDRESS: Address = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";
const TOKEN_ADDRESS: Address = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

const facet_bank = {
  abi: [
    {
      inputs: [],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "employee",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "bonus",
          type: "uint256",
        },
      ],
      name: "Bonus",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "employee",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "budge",
          type: "uint256",
        },
      ],
      name: "Paid",
      type: "event",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_employee",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "_budge",
          type: "uint256",
        },
      ],
      name: "createEmployee",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_employee",
          type: "address",
        },
      ],
      name: "deleteEmployee",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "getAllEmployees",
      outputs: [
        {
          internalType: "address[]",
          name: "employees",
          type: "address[]",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getBalance",
      outputs: [
        {
          internalType: "uint256",
          name: "balance",
          type: "uint256",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_employee",
          type: "address",
        },
      ],
      name: "getEmployee",
      outputs: [
        {
          internalType: "address",
          name: "employee",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "budge",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "bonus",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "getTotalEmployeeCost",
      outputs: [
        {
          internalType: "uint256",
          name: "totalCost",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "payAllEmployees",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_employee",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "_budge",
          type: "uint256",
        },
      ],
      name: "updateEmployee",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ],
  address: BANK_ADDRESS,
};

const diamond = {
  abi: [
    {
      inputs: [
        {
          internalType: "address",
          name: "token",
          type: "address",
        },
      ],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "bytes[]",
          name: "_diamondCut",
          type: "bytes[]",
        },
        {
          indexed: false,
          internalType: "address",
          name: "_init",
          type: "address",
        },
        {
          indexed: false,
          internalType: "bytes",
          name: "_calldata",
          type: "bytes",
        },
      ],
      name: "DiamondCuted",
      type: "event",
    },
    {
      stateMutability: "payable",
      type: "fallback",
    },
    {
      inputs: [
        {
          components: [
            {
              internalType: "address",
              name: "facetAddress",
              type: "address",
            },
            {
              internalType: "enum IDiamondCut.Action",
              name: "action",
              type: "uint8",
            },
            {
              internalType: "bytes4[]",
              name: "functionSelectors",
              type: "bytes4[]",
            },
          ],
          internalType: "struct IDiamondCut.FacetCut[]",
          name: "_diamondCut",
          type: "tuple[]",
        },
        {
          internalType: "address",
          name: "_constructor",
          type: "address",
        },
        {
          internalType: "bytes",
          name: "_calldata",
          type: "bytes",
        },
      ],
      name: "diamondCut",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes4",
          name: "fnSelector",
          type: "bytes4",
        },
      ],
      name: "facetAddress",
      outputs: [
        {
          internalType: "address",
          name: "facetAddress_",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "facetAddresses",
      outputs: [
        {
          internalType: "address[]",
          name: "facetAddresses_",
          type: "address[]",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "facet_",
          type: "address",
        },
      ],
      name: "facetFunctionSelectors",
      outputs: [
        {
          internalType: "bytes4[]",
          name: "fnSelectors",
          type: "bytes4[]",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "facets",
      outputs: [
        {
          components: [
            {
              internalType: "address",
              name: "facetAddress",
              type: "address",
            },
            {
              internalType: "bytes4[]",
              name: "functionSelectors",
              type: "bytes4[]",
            },
          ],
          internalType: "struct IDiamondLoupe.Facet[]",
          name: "facets_",
          type: "tuple[]",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      stateMutability: "payable",
      type: "receive",
    },
  ],
  address: DIAMOND_ADDRESS,
};

const token = {
  abi: [],
  address: TOKEN_ADDRESS,
};

export default {
  token,
  facet_bank,
  diamond,
};
