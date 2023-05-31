import React from "react";
import { stringify } from "viem";
import styles from "./styles";

interface TxDisplayProps {
  receipt: any;
}

export function TxDisplay({ receipt }: TxDisplayProps) {
  return (
    <>
      <styles.ReceiptWrapper>
        <styles.Title>Receipt:</styles.Title>
        <styles.Pre>
          <code>{stringify(receipt, null, 2)}</code>
        </styles.Pre>
      </styles.ReceiptWrapper>
    </>
  );
}
