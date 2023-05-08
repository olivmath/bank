import React, { useState } from "react";
import { Address, createWalletClient, encodePacked, custom } from "viem";
import { foundry } from "viem/chains";
import "viem/window";
import { FunctionSelector } from "./FunctionSelector";
import selectors from "../../config/selectors";
import styles from "./styles";

interface BankProp {
  account: Address;
}

const walletClient = createWalletClient({
  chain: foundry,
  transport: custom(window.ethereum!),
});

function Bank({ account }: BankProp) {
  // STATES
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
      <styles.ConnectedAccount>Connected: {account}</styles.ConnectedAccount>
      <h1>Bank Contract</h1>
      <FunctionSelector selector={selectors.createEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.updateEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.deleteEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.getEmployee}></FunctionSelector>
      <FunctionSelector selector={selectors.getAllEmployees}></FunctionSelector>
      <FunctionSelector selector={selectors.getBalance}></FunctionSelector>
      <FunctionSelector
        selector={selectors.getTotalEmployeeCost}
      ></FunctionSelector>
      <FunctionSelector selector={selectors.payAllEmployees}></FunctionSelector>
    </>
  );
}

export default Bank;
