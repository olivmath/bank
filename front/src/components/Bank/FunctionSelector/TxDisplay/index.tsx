import React from "react";
import styled from "styled-components";
import { stringify } from "viem";

const ReceiptWrapper = styled.div`
  background-color: #f8f9fa;
  border-radius: 4px;
  padding: 16px;
  margin-top: 16px;
`;

const Title = styled.h3`
  margin-bottom: 8px;
`;

const Pre = styled.pre`
  white-space: pre-wrap;
  word-wrap: break-word;
`;

interface TxDisplayProps {
  receipt: any;
}

export function TxDisplay({ receipt }: TxDisplayProps) {
  return (
    <>
      <ReceiptWrapper>
        <Title>Receipt:</Title>
        <Pre>
          <code>{stringify(receipt, null, 2)}</code>
        </Pre>
      </ReceiptWrapper>
    </>
  );
}
