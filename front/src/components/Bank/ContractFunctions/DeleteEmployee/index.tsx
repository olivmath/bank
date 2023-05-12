import contracts, { WalletProps } from "../../../../config/contracts";
import React, { useState, useEffect } from "react";
import { Hash, TransactionReceipt } from "viem";
import { TxDisplay } from "../../TxDisplay";
import { foundry } from "viem/chains";
import styles from "../styles";

export default function ({ account, publicClient, walletClient }: WalletProps) {
  const [isButtonDisabled, setIsButtonDisabled] = useState(true);
  const [receipt, setReceipt] = useState<TransactionReceipt | undefined>();
  const [employee, setEmployee] = useState<string>("");
  const [hash, setHash] = useState<Hash | undefined>();

  useEffect(() => {
    setIsButtonDisabled(!employee);
  }, [employee]);

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
    const hash = await walletClient.writeContract({
      address: contracts.diamond.address,
      abi: contracts.facet_bank.abi,
      functionName: "deleteEmployee",
      args: [employee],
      chain: foundry,
      account,
    });
    setHash(hash);
  };

  return (
    <styles.Wrapper>
      <styles.FunctionName>Delete Employee</styles.FunctionName>
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
        <styles.SendButton onClick={callFunction} disabled={isButtonDisabled}>
          {isButtonDisabled ? "Fill the params!" : "Send"}
        </styles.SendButton>
      </styles.ParamsWrapper>
      {receipt && <TxDisplay receipt={receipt} />}
    </styles.Wrapper>
  );
}
