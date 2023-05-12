import CreateEmployee from "./ContractFunctions/CreateEmployee";
import UpdateEmployee from "./ContractFunctions/UpdateEmployee";
import DeleteEmployee from "./ContractFunctions/DeleteEmployee";
import contracts, { WalletProps } from "../../config/contracts";
import PayEmployees from "./ContractFunctions/PayEmployees";
import React, { useEffect, useState } from "react";
import { formatUnits } from "viem";
import styles from "./styles";
import "viem/window";

interface Employee {
  addr: string;
  budge: number;
  bonus: number;
}

export default function ({ account, publicClient, walletClient }: WalletProps) {
  const [employees, setEmployees] = useState<Employee[]>([]);
  const [totalBonus, setTotalBonus] = useState<number>(0);
  const [totalCost, setTotalCost] = useState<number>(0);
  const [balance, setBalance] = useState<number>(0);
  const [payed, setPayed] = useState<number>(0);

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

    async function totalPayed() {
      const data = await publicClient.readContract({
        abi: contracts.facet_bank_v2.abi,
        address: contracts.diamond.address,
        functionName: "getTotalPayments",
      });
      setPayed(Number(data));
    }

    getAllEmployees();
    getBalance();
    totalPayed();
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
              <p>Total Payeds: {payed}</p>
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
        <PayEmployees
          account={account}
          publicClient={publicClient}
          walletClient={walletClient}
        />
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
