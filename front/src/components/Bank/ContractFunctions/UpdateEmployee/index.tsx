import contracts from "../../../../config/contracts";
import React, { useState, useEffect } from "react";
import { TxDisplay } from "../../TxDisplay";
import { foundry } from "viem/chains";
import styles from "../styles";
import {
  Address,
  Hash,
  PublicClient,
  TransactionReceipt,
  WalletClient,
  parseUnits,
} from "viem";

interface CreateEmployeeProps {
  account: Address;
  publicClient: PublicClient;
  walletClient: WalletClient;
}

export default function CreateEmployee({
  account,
  publicClient,
  walletClient,
}: CreateEmployeeProps) {
  const [isButtonDisabled, setIsButtonDisabled] = useState(true);
  const [receipt, setReceipt] = useState<TransactionReceipt | undefined>();
  const [employee, setEmployee] = useState<string>("");
  const [newBudge, setNewBudge] = useState<string>("");
  const [hash, setHash] = useState<Hash | undefined>();

  useEffect(() => {
    setIsButtonDisabled(!(employee && newBudge));
  }, [employee, newBudge]);

  useEffect(() => {
    const fetchReceipt = async () => {
      if (hash) {
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        setReceipt(receipt);
      }
    };

    fetchReceipt();
  }, [hash, publicClient]);

  const callFunction = async () => {
    const parsedBudge = parseUnits(newBudge, 18);
    const hash = await walletClient.writeContract({
      address: contracts.diamond.address,
      abi: contracts.facet_bank.abi,
      functionName: "updateEmployee",
      args: [employee, parsedBudge],
      chain: foundry,
      account,
    });
    setHash(hash);
  };

  return (
    <styles.Wrapper>
      <styles.FunctionName>Update Employee</styles.FunctionName>
      <styles.ParamsWrapper>
        <styles.InputWrapper>
          <styles.InputLabel>Employee</styles.InputLabel>
          <styles.InputText
            type="text"
            placeholder={"0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"}
            value={employee}
            onChange={(e) => setEmployee(e.target.value)}
          />
        </styles.InputWrapper>
        <styles.InputWrapper>
          <styles.InputLabel>New Budge</styles.InputLabel>
          <styles.Input
            type="text"
            placeholder={"1000"}
            value={newBudge}
            onChange={(e) => setNewBudge(e.target.value)}
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
