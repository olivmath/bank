import React, { useState, useEffect } from "react";
import {
  Address,
  Hash,
  PublicClient,
  TransactionReceipt,
  WalletClient,
} from "viem";
import { TxDisplay } from "../../TxDisplay";
import styles from "../styles";
import contracts from "../../../../config/contracts";
import { foundry } from "viem/chains";

interface CreateEmployeeProps {
  account: Address;
  publicClient: PublicClient;
  walletClient: WalletClient;
}

export default function ({
  account,
  publicClient,
  walletClient,
}: CreateEmployeeProps) {
  const [isButtonDisabled, setIsButtonDisabled] = useState(false);
  const [receipt, setReceipt] = useState<TransactionReceipt>();
  const [employee, setEmployee] = useState<string>();
  const [hash, setHash] = useState<Hash>();

  useEffect(() => {
    const truth = [employee].every(
      (value) => value !== undefined && value !== ""
    );
    setIsButtonDisabled(!truth);
  }, [employee]);

  useEffect(() => {
    (async () => {
      if (hash) {
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        setReceipt(receipt);
      }
    })();
  }, [hash]);

  const callFunction = async () => {
    const hash = await walletClient.writeContract({
      address: contracts.diamond.address,
      abi: contracts.facet_bank.abi,
      functionName: "deleteEmployee",
      args: [employee],
      chain: foundry,
      account,
    });
    setHash(hash as Hash);
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
            onChange={(e) => {
              setEmployee(e.target.value);
            }}
          />
        </styles.InputWrapper>
        <styles.SendButton
          onClick={() => callFunction()}
          disabled={isButtonDisabled}
        >
          {isButtonDisabled ? "Fill the params!" : "Send"}
        </styles.SendButton>
      </styles.ParamsWrapper>
      {receipt && <TxDisplay receipt={receipt} />}
    </styles.Wrapper>
  );
}
