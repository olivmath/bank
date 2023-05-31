import contracts, { WalletProps } from "../../../../config/contracts";
import { Hash, TransactionReceipt, parseUnits } from "viem";
import React, { useState, useEffect } from "react";
import { TxDisplay } from "../../TxDisplay";
import { foundry } from "viem/chains";
import styles from "../styles";

export default function ({ account, publicClient, walletClient }: WalletProps) {
  const [isButtonDisabled, setIsButtonDisabled] = useState(true);
  const [receipt, setReceipt] = useState<TransactionReceipt | undefined>();
  const [employee, setEmployee] = useState<string>("");
  const [budge, setBudge] = useState<string>("");
  const [hash, setHash] = useState<Hash | undefined>();

  useEffect(() => {
    setIsButtonDisabled(!(employee && budge));
  }, [employee, budge]);

  useEffect(() => {
    const fetchReceipt = async () => {
      if (hash) {
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        setReceipt(receipt);
      }
    };

    fetchReceipt();
  }, [hash]);

  const callFunction = async () => {
    const parsedBudge = parseUnits(budge, 18);
    const hash = await walletClient.writeContract({
      address: contracts.diamond.address,
      abi: contracts.facet_bank.abi,
      functionName: "createEmployee",
      args: [employee, parsedBudge],
      chain: foundry,
      account,
    });
    setHash(hash);
  };

  return (
    <styles.Wrapper>
      <styles.FunctionName>Create Employee</styles.FunctionName>
      <styles.ParamsWrapper>
        <styles.InputWrapper>
          <styles.InputLabel>New Employee</styles.InputLabel>
          <styles.InputText
            type="text"
            placeholder={"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"}
            value={employee}
            onChange={(e) => setEmployee(e.target.value)}
          />
        </styles.InputWrapper>
        <styles.InputWrapper>
          <styles.InputLabel>Budge</styles.InputLabel>
          <styles.Input
            type="text"
            placeholder={"1000"}
            value={budge}
            onChange={(e) => setBudge(e.target.value)}
          />
        </styles.InputWrapper>
        <styles.SendButton onClick={callFunction} disabled={isButtonDisabled}>
          {isButtonDisabled ? "Fill the params!" : "Send"}
        </styles.SendButton>
      </styles.ParamsWrapper>
      {receipt && <TxDisplay receipt={receipt} />}
    </styles.Wrapper>
  );
}
