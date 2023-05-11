import React, { useState } from "react";
import { foundry } from "viem/chains";
import Employee from "../Employee";
import styles from "./styles";
import Bank from "../Bank";
import "viem/window";
import {
  Address,
  createPublicClient,
  createWalletClient,
  custom,
  http,
} from "viem";

const CONTROLLER = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

const publicClient = createPublicClient({
  chain: foundry,
  transport: http(),
});

const walletClient = createWalletClient({
  chain: foundry,
  transport: custom(window.ethereum!),
});

export default function () {
  const [account, setAccount] = useState<Address | null>(null);

  const connect = async () => {
    const [address] = await walletClient.requestAddresses();
    setAccount(address);
  };

  return (
    <div>
      {account ? (
        account === CONTROLLER ? (
          <Bank
            account={account}
            publicClient={publicClient}
            walletClient={walletClient}
          />
        ) : (
          <Employee account={account} />
        )
      ) : (
        <styles.ConnectButton onClick={connect}>
          Connect Wallet
        </styles.ConnectButton>
      )}
    </div>
  );
}
