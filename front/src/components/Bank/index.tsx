import CreateEmployee from "./ContractFunctions/CreateEmployee";
import UpdateEmployee from "./ContractFunctions/UpdateEmployee";
import DeleteEmployee from "./ContractFunctions/DeleteEmployee";
import { Address, PublicClient, WalletClient } from "viem";
import styles from "./styles";
import React from "react";
import "viem/window";

const employees = Array(10).fill({ address: "0x0", budge: 10000, bonus: 300 });

interface BankProp {
  account: Address;
  publicClient: PublicClient;
  walletClient: WalletClient;
}

function Bank({ account, publicClient, walletClient }: BankProp) {
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
      <CreateEmployee
        account={account}
        publicClient={publicClient}
        walletClient={walletClient}
      />
      <UpdateEmployee
        account={account}
        publicClient={publicClient}
        walletClient={walletClient}
      />
      <DeleteEmployee
        account={account}
        publicClient={publicClient}
        walletClient={walletClient}
      />
    </>
  );
}
export default Bank;
