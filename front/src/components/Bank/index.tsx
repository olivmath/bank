import React from "react";
import { Address } from "viem";
import "viem/window";
import { FunctionSelector } from "./FunctionSelector";
import selectors from "../../config/selectors";
import styles from "./styles";

interface BankProp {
  account: Address;
}

function Bank({ account }: BankProp) {
  // COMPONENT

  return (
    <>
      <styles.ConnectedAccount>Connected: {account}</styles.ConnectedAccount>
      <h1>Bank Contract</h1>
      <FunctionSelector
        account={account}
        selector={selectors.createEmployee}
      ></FunctionSelector>
      <FunctionSelector
        account={account}
        selector={selectors.updateEmployee}
      ></FunctionSelector>
      <FunctionSelector
        account={account}
        selector={selectors.deleteEmployee}
      ></FunctionSelector>
      <FunctionSelector
        account={account}
        selector={selectors.getEmployee}
      ></FunctionSelector>
      <FunctionSelector
        account={account}
        selector={selectors.getAllEmployees}
      ></FunctionSelector>
      <FunctionSelector
        account={account}
        selector={selectors.getBalance}
      ></FunctionSelector>
      <FunctionSelector
        account={account}
        selector={selectors.getTotalEmployeeCost}
      ></FunctionSelector>
      <FunctionSelector
        account={account}
        selector={selectors.payAllEmployees}
      ></FunctionSelector>
    </>
  );
}

export default Bank;
