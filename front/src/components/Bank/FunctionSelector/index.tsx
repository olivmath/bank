import React, { useState, useEffect } from "react";
import styles from "./styles";
import { StaticCall } from "../../../config/selectors";
import {
  Address,
  Hash,
  TransactionReceipt,
  createPublicClient,
  createWalletClient,
  custom,
  encodePacked,
  http,
} from "viem";
import { foundry } from "viem/chains";
import { TxDisplay } from "./TxDisplay";

const contractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

interface FunctionSelectorProps {
  selector: StaticCall;
  account: Address;
}

const publicClient = createPublicClient({
  chain: foundry,
  transport: http(),
});

const walletClient = createWalletClient({
  chain: foundry,
  transport: custom(window.ethereum!),
});

export function FunctionSelector({ selector, account }: FunctionSelectorProps) {
  const [hash, setHash] = useState<Hash>();
  const [receipt, setReceipt] = useState<TransactionReceipt>();
  const [isButtonDisabled, setIsButtonDisabled] = useState(false);
  const [inputValues, setInputValues] = useState<any[]>(
    Array(selector.params.length).fill(undefined)
  );

  // USE EFFECT

  useEffect(() => {
    const areAllInputsFilled = inputValues.every(
      (value) => value !== undefined && value !== ""
    );
    setIsButtonDisabled(!areAllInputsFilled);
  }, [inputValues]);

  useEffect(() => {
    (async () => {
      if (hash) {
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        console.log(receipt);
        setReceipt(receipt);
      }
    })();
  }, [hash]);

  // FUNCTIONS

  const handleInputChange = (index: number, value: any) => {
    const newValues = [...inputValues];
    newValues[index] = value;
    setInputValues(newValues);
  };

  const callFunction = async (
    funcSelector: string,
    types: string[],
    values: any[]
  ) => {
    const data = encodePacked(types, [funcSelector, ...values]);
    const hash = await walletClient.sendTransaction({
      to: contractAddress,
      account,
      data: data,
    });

    setHash(hash);
  };

  // COMPONENT

  return (
    <styles.Wrapper>
      <styles.FunctionName>{selector.name}</styles.FunctionName>
      <styles.ParamsWrapper>
        {selector.params.map((param, index) => (
          <styles.InputWrapper key={index}>
            <styles.InputLabel>{param}</styles.InputLabel>
            <styles.Input
              type="text"
              placeholder={`Enter ${selector.types[index + 1]}`}
              onChange={(e) => {
                console.log(e.target.value);
                handleInputChange(index, e.target.value);
              }}
            />
          </styles.InputWrapper>
        ))}
        <styles.SendButton
          onClick={() =>
            callFunction(selector.selector, selector.types, inputValues)
          }
          disabled={isButtonDisabled}
        >
          {isButtonDisabled ? "Fill the params!" : "Send"}
        </styles.SendButton>
      </styles.ParamsWrapper>
      {receipt && <TxDisplay receipt={receipt} />}
    </styles.Wrapper>
  );
}
