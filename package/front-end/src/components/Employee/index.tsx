import { Address, PublicClient, formatUnits } from "viem";
import React, { useEffect, useState } from "react";
import contracts from "../../config/contracts";
import Styles from "./styles";


export default function ({
  account,
  publicClient,
}: {
  account: Address;
  publicClient: PublicClient;
}) {
  const [employeeData, setEmployeeData] = useState<{
    budge: string;
    bonus: string;
  } | null>(null);

  useEffect(() => {
    async function getEmployee() {
      const data = await publicClient.readContract({
        abi: contracts.facet_bank.abi,
        address: contracts.diamond.address,
        functionName: "getEmployee",
        args: [account],
      });

      setEmployeeData({
        budge: formatUnits(data[1], 18),
        bonus: formatUnits(data[2], 18),
      });
    }
    getEmployee();
  }, [account]);

  if (!employeeData) {
    return <div>Carregando...</div>;
  }

  return (
    <div>
      <Styles.ConnectedAccount>Connected: {account}</Styles.ConnectedAccount>
      <Styles.Title>Employee {account}</Styles.Title>
      <Styles.Info>
        Your budge: {employeeData.budge || "Carregando..."}
      </Styles.Info>
      <Styles.Info>
        Have bonus: {employeeData.bonus || "Carregando..."}
      </Styles.Info>
    </div>
  );
}
