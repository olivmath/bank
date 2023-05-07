import React, { useState } from "react";

export interface StaticCall {
  name: string;
  selector: string;
  types: string[];
  values: any[];
  params: string[];
}

interface FunctionSelectorProps {
  selector: StaticCall;
}

export function FunctionSelector({ selector }: FunctionSelectorProps) {
  const [inputValues, setInputValues] = useState<any[]>([]);

  const handleInputChange = (index: number, value: any) => {
    const newValues = [...inputValues];
    newValues[index] = value;
    setInputValues(newValues);
  };

  return (
    <div
      style={{ display: "flex", alignItems: "center", marginBottom: "10px" }}
    >
      <h2 style={{ marginRight: "10px" }}>{selector.name}</h2>
      {selector.params.map((param, index) => (
        <div key={index} style={{ marginRight: "10px" }}>
          <label>{param}</label>
          <input
            type="text"
            onChange={(e) => handleInputChange(index, e.target.value)}
          />
        </div>
      ))}
      <button>Send</button>
    </div>
  );
}
