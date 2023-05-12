import { Hash } from "viem";
import contracts, { WalletProps } from "../../../../config/contracts";
import styles from "../styles";
import React, { useEffect, useState } from "react";
import { foundry } from "viem/chains";

export default function ({ account, publicClient, walletClient }: WalletProps) {
  const [hash, setHash] = useState<Hash | undefined>();

  useEffect(() => {
    const fetchReceipt = async () => {
      if (hash) {
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        console.log(receipt);
      }
    };

    fetchReceipt();
  }, [hash]);

  const payEmployee = async () => {
    const data = await walletClient.writeContract({
      abi: contracts.facet_bank.abi,
      address: contracts.diamond.address,
      functionName: "payAllEmployees",
      account,
      chain: foundry,
    });

    console.log(data);
    setHash(hash);
  };

  const deposit = async () => {
    const cost = await publicClient.readContract({
      abi: contracts.facet_bank.abi,
      address: contracts.diamond.address,
      functionName: "getTotalEmployeeCost",
    });
    const balance = await publicClient.readContract({
      abi: contracts.facet_bank.abi,
      address: contracts.diamond.address,
      functionName: "getBalance",
    });

    if (cost > balance) {
      console.log("tem q depoistar");
      const hash = await walletClient.writeContract({
        abi: contracts.token.abi,
        address: contracts.token.address,
        functionName: "transfer",
        args: [contracts.diamond.address, cost - balance],
        account,
        chain: foundry,
      });
      setHash(hash);
    } else {
      alert("Balance already ok!");
    }
  };

  return (
    <div style={{ display: "flex", justifyContent: "center" }}>
      <styles.PayButton onClick={deposit}>Cover the cost</styles.PayButton>
      <styles.PayButton onClick={payEmployee}>
        Pay All Employee
      </styles.PayButton>
    </div>
  );
}
