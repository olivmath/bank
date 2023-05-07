import React, { useState } from "react";
import { Address, createWalletClient, encodePacked, custom } from "viem";
import { foundry } from "viem/chains";import "viem/window";
import DiamondFunctions, { StaticCall } from "./selectors";
import { FunctionSelector } from "./FunctionSelector";
import selectors from "./selectors";


interface BankProp {
  account: Address;
}

const walletClient = createWalletClient({
    chain: foundry,
    transport: custom(window.ethereum!),
  });
  

function Bank({ account }: BankProp) {
  // STATES

  const [inputTypes, setInputTypes] = useState<Address[]>([]);
  const [employee, setEmployee] = useState<Address>();
  const [inputBudge, setInputBudge] = useState(0);
  const contractAddress: Address = "0x1234";

  // FUNCTIONS

  const callFunction = async (
    funcSelector: string,
    types: string[],
    values: any[]
  ) => {
    const data = encodePacked(types, [funcSelector, ...values]);
    const hash = await walletClient.sendTransaction({
      data: data,
      account,
      to: contractAddress,
    });
  };


  // COMPONENT

  return (
    <>
      <div>Connected: {account}</div>
      <h1>Bank Contract</h1>
      <FunctionSelector selector={selectors.createEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.updateEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.deleteEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.getEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.getAllEmployees}></FunctionSelector>
      <FunctionSelector selector={selectors.getBalance}></FunctionSelector>
      <FunctionSelector selector={selectors.getTotalEmployeeCost}></FunctionSelector>
      <FunctionSelector selector={selectors.payAllEmployees}></FunctionSelector>
    </>
  );
}

export default Bank;
