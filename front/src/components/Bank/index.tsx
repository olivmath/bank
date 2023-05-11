import React from "react";
import { Address } from "viem";
import "viem/window";
import { FunctionSelector } from "./FunctionSelector";
import selectors from "../../config/selectors";
import styles from "./styles";

const employees = Array(10).fill({ address: "0x0", budge: 10000, bonus: 300 });

interface BankProp {
  account: Address;
}

function Bank({ account }: BankProp) {
  // COMPONENT
  return (
    <>
      <styles.ConnectedAccount>Connected: {account}</styles.ConnectedAccount>
      <h1>Bank Contract</h1>
      <styles.Container>
        <div>
          <h2>Info</h2>
          <styles.Column1>
            <p>Total Cost: {1000}</p>
            <p>Balance: {1200}</p>
            <p>Total Employess: {employees.length}</p>
            <p>Total Bonus: {200}</p>
          </styles.Column1>
        </div>
        <div>
          <h2>Employees</h2>
          <styles.Column2>
            {employees.map((employee, index) => (
              <p key={index}>
                Address: {employee.address}, Budget: {employee.budge}, Bonus:{" "}
                {employee.bonus}
              </p>
            ))}
          </styles.Column2>
        </div>
      </styles.Container>
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
    </>
  );
}

export default Bank;
