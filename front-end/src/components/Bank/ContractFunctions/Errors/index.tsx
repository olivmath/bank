import contracts, { WalletProps } from "../../../../config/contracts";
import React, { useState, useEffect } from "react";
import { foundry } from "viem/chains";
import styles from "../styles";
import { Hash } from "viem";

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

  const callFunction = async (functionName: string) => {
    try {
      const hash = await walletClient.writeContract({
        address: contracts.diamond.address,
        abi: contracts.facet_errors.abi,
        functionName: functionName,
        chain: foundry,
        account,
      });
      setHash(hash);
    } catch (error) {
      console.error("Error occurred:", error);
    }
  };

  return (
    <>
      <styles.Wrapper>
        <styles.FunctionName>Revert Without Args</styles.FunctionName>
        <styles.SendButton onClick={() => callFunction("withoutArgs")}>
          Send
        </styles.SendButton>
      </styles.Wrapper>
      <styles.Wrapper>
        <styles.FunctionName>Revert With Multiple Args</styles.FunctionName>
        <styles.SendButton onClick={() => callFunction("withMultipleArgs")}>
          Send
        </styles.SendButton>
      </styles.Wrapper>
      <styles.Wrapper>
        <styles.FunctionName>Revert With Require</styles.FunctionName>
        <styles.SendButton onClick={() => callFunction("withRequire")}>
          Send
        </styles.SendButton>
      </styles.Wrapper>
    </>
  );
}
