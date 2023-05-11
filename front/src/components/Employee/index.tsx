import React, { useEffect, useState } from "react";
import { Address, createPublicClient, http } from "viem";
import Styles from "./styles";
import { foundry } from "viem/chains";
import contracts from "../../config/contracts";

interface EmployeeProps {
  account: Address;
}

const client = createPublicClient({
  chain: foundry,
  transport: http(),
});

function Employees({ account }: EmployeeProps) {
  const [budge, setBudge] = useState<Address>();
  const [bonus, setBonus] = useState<number>();

  useEffect(() => {
    function getEmployee() {
      const data = client.readContract({
        abi: contracts.facet_bank.abi,
        address: contracts.diamond.address,
        functionName: "getEmployee",
        args: [account],
      });

      console.log(data);

      setBudge(data[0]);
      setBonus(data[1]);
    }
    getEmployee();
  }, []);

  return (
    <>
      <div>
        <Styles.ConnectedAccount>Connected: {account}</Styles.ConnectedAccount>
        <Styles.Title>Employee {account}</Styles.Title>
        <Styles.Info>Your budge: {budge}</Styles.Info>
        <Styles.Info>Have bonus: {bonus}</Styles.Info>
      </div>
    </>
  );
}

export default Employees;
