import React from "react";
import { Address } from "viem";
import Styles from "./styles";

interface EmployeeProps {
  account: Address;
}

function Employees({ account }: EmployeeProps) {
  // Busque informações do funcionário (budge e bonus) e defina o estado
  const [budge, bonus] = [123, 0];

  return (
    <>
      <div>
        <Styles.ConnectedAccount>
          Connected: {account}
        </Styles.ConnectedAccount>
        <Styles.Title>Employee {account}</Styles.Title>
        <Styles.Info>Your budge: {budge}</Styles.Info>
        <Styles.Info>Have bonus: {bonus}</Styles.Info>
      </div>
    </>
  );
}

export default Employees;
