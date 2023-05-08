import styled from "styled-components";

export default {
  Wrapper: styled.div`
    display: flex;
    flex-direction: column;
    margin-bottom: 16px;
  `,
  FunctionName: styled.h2`
    margin-bottom: 8px;
    font-weight: bold;
  `,
  ParamsWrapper: styled.div`
    display: flex;
    align-items: flex-end;
  `,
  InputWrapper: styled.div`
    display: flex;
    flex-direction: column;
    margin-right: 16px;
  `,
  InputLabel: styled.label`
    font-size: 12px;
    color: #555;
    margin-bottom: 4px;
  `,
  Input: styled.input`
    width: 200px;
    padding: 6px 12px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 14px;
  `,
  SendButton: styled.button`
    padding: 6px 12px;
    background-color: ${({ disabled }) => (disabled ? "#ccc" : "#007bff")};
    color: #fff;
    border: 1px solid ${({ disabled }) => (disabled ? "#ccc" : "#007bff")};
    border-radius: 4px;
    cursor: ${({ disabled }) => (disabled ? "not-allowed" : "pointer")};
    transition: background-color 0.2s;

    &:hover {
      background-color: ${({ disabled }) => (disabled ? "#ccc" : "#0056b3")};
      border-color: ${({ disabled }) => (disabled ? "#ccc" : "#0056b3")};
    }
  `,
};
