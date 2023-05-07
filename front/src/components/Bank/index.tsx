import React, { useState } from "react";
import { Address, createWalletClient, encodePacked, custom } from "viem";
import { foundry } from "viem/chains";import "viem/window";


interface BankProp {
  account: Address;
}

const walletClient = createWalletClient({
    chain: foundry,
    transport: custom(window.ethereum!),
  });
  

function Bank({ account }: BankProp) {
  // STATES

  const [showInputs, setShowInputs] = useState(false);
  const [inputTypes, setInputTypes] = useState<Address[]>([]);
  const [employee, setEmployee] = useState<Address>();
  const [inputBudge, setInputBudge] = useState(0);
  const contractAddress: Address = "0x1234";

  // FUNCTIONS

  const callFunction = async (
    funcSelector: string,
    types: string[],
    values: any[]
  ) => {
    const data = encodePacked(types, [funcSelector, ...values]);
    const hash = await walletClient.sendTransaction({
      data: data,
      account,
      to: contractAddress,
    });
  };

  const handleButtonClick = (
    funcSelector: string,
    types: string[] = [],
    values: any[] = []
  ) => {
    setShowInputs(true);
    setInputTypes(types);
    callFunction(funcSelector, types, values);
  };

  const renderInputs = () => {
    return inputTypes.map((type, index) => {
      let inputLabel;
      let inputValue;
      let setInputValue;

      if (type === "address") {
        inputLabel = "Employee Address";
        inputValue = employee;
        setInputValue = setEmployee;
      } else if (type === "uint256") {
        inputLabel = "Budge";
        inputValue = inputBudge;
        setInputValue = setInputBudge;
      }

      return (
        <div key={index}>
          <label>{inputLabel}</label>
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
          />
        </div>
      );
    });
  };

  const renderButton = (
    text: string,
    funcSelector: string,
    types: string[] = [],
    values: any[] = []
  ) => (
    <div>
      <button onClick={() => handleButtonClick(funcSelector, types, values)}>
        {text}
      </button>
    </div>
  );

  // COMPONENT

  return (
    <>
      <div>Connected: {account}</div>
      <h1>Bank Contract</h1>
      {renderButton(
        "createEmployee",
        "0x520a19c0",
        ["bytes4", "address", "uint256"],
        [employee, inputBudge]
      )}
      {renderButton(
        "updateEmployee",
        "0x5e91d8ec",
        ["bytes4", "address", "uint256"],
        [employee, inputBudge]
      )}
      {renderButton(
        "deleteEmployee",
        "0x6e7c4ab1",
        ["bytes4", "address"],
        [employee]
      )}
      {renderButton("getAllEmployees", "0xe3366fed", ["bytes4"])}
      {renderButton(
        "getEmployee",
        "0x32648e09",
        ["bytes4", "address"],
        [employee]
      )}
      {renderButton("payAllEmployees", "0x809e9ef5", ["bytes4"])}
      {renderButton("getBalance", "0x12065fe0", ["bytes4"])}
      {renderButton("getTotalEmployeeCost", "0x1e153139", ["bytes4"])}

      {showInputs && (
        <div>
          {renderInputs()}
          <button
            onClick={() =>
              handleButtonClick(
                "0x520a19c0",
                ["bytes4", "address", "uint256"],
                [employee, inputBudge]
              )
            }
          >
            Send
          </button>
        </div>
      )}
    </>
  );
}

export default Bank;
