import React from "react";
import { Address } from "viem";

interface EmployeeProps {
  account: Address;
}

function Employees({ account }: EmployeeProps) {
  // Busque informações do funcionário (budge e bonus) e defina o estado
  const [budge, bonus] = [123, 0];

  return (
    <>
      <div>Connected: {account}</div>
      <h1>Employee {account}</h1>
      <p>Your budge: {budge}</p>
      <p>Have bonus: {bonus}</p>
    </>
  );
}

export default Employees;
