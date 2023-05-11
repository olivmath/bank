import { Address, PublicClient, WalletClient, formatUnits } from "viem";
import CreateEmployee from "./ContractFunctions/CreateEmployee";
import UpdateEmployee from "./ContractFunctions/UpdateEmployee";
import DeleteEmployee from "./ContractFunctions/DeleteEmployee";
import React, { useEffect, useState } from "react";
import contracts from "../../config/contracts";
import styles from "./styles";
import "viem/window";

interface Employee {
  addr: string;
  budge: number;
  bonus: number;
}

interface BankProps {
  account: Address;
  publicClient: PublicClient;
  walletClient: WalletClient;
}

export default function Bank({
  account,
  publicClient,
  walletClient,
}: BankProps) {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [totalBonus, setTotalBonus] = useState<number>(0);
  const [totalCost, setTotalCost] = useState<number>(0);
  const [balance, setBalance] = useState<number>(0);

  useEffect(() => {
    async function getAllEmployees() {
      const data = await publicClient.readContract({
        abi: contracts.facet_bank.abi,
        address: contracts.diamond.address,
        functionName: "getAllEmployees",
      });
      const employeePromises = await Promise.all(
        data.map(async (emplAddr) => {
          const empl = await publicClient.readContract({
            abi: contracts.facet_bank.abi,
            address: contracts.diamond.address,
            functionName: "getEmployee",
            args: [emplAddr],
          });

          const budge = Number(formatUnits(empl[1], 18));
          const bonus = Number(formatUnits(empl[2], 18));

          setTotalBonus((prevTotalBonus) => prevTotalBonus + bonus);
          setTotalCost((prevTotalCost) => prevTotalCost + budge);

          return {
            addr: empl[0],
            budge,
            bonus,
          };
        })
      );

      setEmployees(employeePromises);
    }

    async function getBalance() {
      const data = await publicClient.readContract({
        abi: contracts.token.abi,
        address: contracts.token.address,
        functionName: "balanceOf",
        args: [contracts.diamond.address],
      });

      setBalance(Number(formatUnits(data, 18)));
    }

    getAllEmployees();
    getBalance();
  }, []);

  return (
    <>
      <styles.ConnectedAccount>Connected: {account}</styles.ConnectedAccount>
      <h1>Bank Contract</h1>
      <div>
        <styles.Container>
          <div>
            <h2>Info</h2>
            <styles.Column1>
              <p>Total Cost: {totalCost}</p>
              <p>Balance: {balance}</p>
              <p>Total Employees: {employees.length}</p>
              <p>Total Bonus: {totalBonus}</p>
            </styles.Column1>
          </div>
          <div>
            <h2>Employees</h2>
            <styles.Column2>
              {employees.map((employee, index) => (
                <p key={index}>
                  addr: {employee.addr}, budge: {employee.budge}, bonus:{" "}
                  {employee.bonus}
                </p>
              ))}
            </styles.Column2>
          </div>
        </styles.Container>
      </div>
      <div>
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
      </div>
    </>
  );
}
