import React, { useState } from "react";
import styles from "./styles";
import { StaticCall } from "../../../config/selectors";

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
    <styles.Wrapper>
      <styles.FunctionName>{selector.name}</styles.FunctionName>
      <styles.ParamsWrapper>
        {selector.params.map((param, index) => (
          <styles.InputWrapper key={index}>
            <styles.InputLabel>{param}</styles.InputLabel>
            <styles.Input
              type="text"
              placeholder={`Enter ${selector.types[index + 1]}`} // Adicione esta linha
              onChange={(e) => handleInputChange(index, e.target.value)}
            />
          </styles.InputWrapper>
        ))}
        <styles.SendButton>Send</styles.SendButton>
      </styles.ParamsWrapper>
    </styles.Wrapper>
  );
}
