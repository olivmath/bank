import styled from "styled-components";

const Column = styled.div`
  flex: 1;
`;

const Column1 = styled(Column)`
  margin-right: 10px;
`;

const Column2 = styled(Column)`
  margin-left: 10px;
  height: 150px;
  overflow-y: scroll;
`;

export default {
  ConnectedAccount: styled.div`
    font-size: 24px;
    font-weight: 500;
    display: flex;
    color: white;
    align-items: center;
    justify-content: center;
    text-align: center;
    border-radius: 8px;
    padding: 8px;
    background-color: #007bff;
  `,
  Container: styled.div`
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: flex-start;
  `,
  Column,
  Column1,
  Column2,
};
