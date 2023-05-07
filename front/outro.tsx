import React, { useEffect, useState } from "react";
import ReactDOM from "react-dom/client";
import {
  Address,
  Hash,
  TransactionReceipt,
  createPublicClient,
  createWalletClient,
  custom,
  http,
  parseEther,
  stringify,
} from "viem";
import { foundry } from "viem/chains";
import "viem/window";
import { encodePacked } from "viem";

const contractAddress = "0x1234";

const publicClient = createPublicClient({
  chain: foundry,
  transport: http(),
});
const walletClient = createWalletClient({
  chain: foundry,
  transport: custom(window.ethereum!),
});

function Example() {
  const [account, setAccount] = useState<Address>();
  const [hash, setHash] = useState<Hash>();
  const [receipt, setReceipt] = useState<TransactionReceipt>();

  const [isEmployee, setIsEmployee] = useState<boolean>();
  const [budge, setBudge] = useState<number>();
  const [bonus, setBonus] = useState<number>();

  const [showInputs, setShowInputs] = useState(false);
  const [inputTypes, setInputTypes] = useState([]);
  const [employee, setEmployee] = useState("0x");
  const [inputBudge, setInputBudge] = useState(0);

  const connect = async () => {
    const [address] = await walletClient.requestAddresses();
    setAccount(address);
  };

  const sendTransaction = async () => {
    setHash("0x1233");
  };

  useEffect(() => {
    (async () => {
      if (hash) {
        const receipt = await publicClient.waitForTransactionReceipt({ hash });
        setReceipt(receipt);
      }
    })();
  }, [hash]);

  useEffect(() => {
    if (account) {
      if (account === "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266") {
        setIsEmployee(false);
      } else {
        setIsEmployee(true);
        // Busque informações do funcionário (budge e bonus) e defina o estado
        // [budge, bonus] = contract.getEmployee(account)
        const [_budge, _bonus] = [123, 0];
        setBudge(_budge);
        setBonus(_bonus);
      }
    }
  }, [account]);

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
    setHash(hash);
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
        inputValue = budge;
        setInputValue = setBudge;
      }

      return (
        <div key={index}>
          <label>{inputLabel}:</label>
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
          />
        </div>
      );
    });
  };

  if (account) {
    if (isEmployee) {
      return (
        <>
          <div>Connected: {account}</div>
          <h1>Employee {account}</h1>
          <p>Your budge: {budge}</p>
          <p>Have bonus: {bonus}</p>
        </>
      );
    } else {
      return (
        <>
          <div>Connected: {account}</div>
          <h1>Bank Contract</h1>
          <div>
            <button
              onClick={() =>
                handleButtonClick(
                  "0x520a19c0",
                  ["bytes4", "address", "uint256"],
                  [employee, inputBudge]
                )
              }
            >
              createEmployee
            </button>
          </div>
          <div>
            <button
              onClick={() =>
                handleButtonClick(
                  "0x5e91d8ec",
                  ["bytes4", "address", "uint256"],
                  [employee, inputBudge]
                )
              }
            >
              updateEmployee
            </button>
          </div>
          <div>
            <button
              onClick={() =>
                handleButtonClick(
                  "0x6e7c4ab1",
                  ["bytes4", "address"],
                  ["0xdeadbeefdeadbeefdeadbeefdeadbeef"]
                )
              }
            >
              deleteEmployee
            </button>
          </div>
          <div>
            <button
              onClick={() => handleButtonClick("0xe3366fed", ["bytes4"], [])}
            >
              getAllEmployees
            </button>
          </div>
          <div>
            <button
              onClick={() =>
                handleButtonClick(
                  "0x32648e09",
                  ["bytes4", "address"],
                  ["0xdeadbeefdeadbeefdeadbeefdeadbeef"]
                )
              }
            >
              getEmployee
            </button>
          </div>
          <div>
            <button
              onClick={() => handleButtonClick("0x809e9ef5", ["bytes4"], [])}
            >
              payAllEmployees
            </button>
          </div>
          <div>
            <button
              onClick={() => handleButtonClick("0x12065fe0", ["bytes4"], [])}
            >
              getBalance
            </button>
          </div>
          <div>
            <button
              onClick={() => handleButtonClick("0x1e153139", ["bytes4"], [])}
            >
              getTotalEmployeeCost
            </button>
          </div>
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
  }
  return <button onClick={connect}>Connect Wallet</button>;
}

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <Example />
);88