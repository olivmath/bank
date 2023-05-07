export interface StaticCall {
  name: string;
  selector: string;
  types: string[];
  values: any[];
}

const createEmployee: StaticCall = {
  name: "createEmployee",
  selector: "0x520a19c0",
  types: ["bytes4", "address", "uint256"],
  values: [],
};
const updateEmployee: StaticCall = {
  name: "updateEmployee",
  selector: "0x5e91d8ec",
  types: ["bytes4", "address", "uint256"],
  values: [],
};
const deleteEmployee: StaticCall = {
  name: "deleteEmployee",
  selector: "0x6e7c4ab1",
  types: ["bytes4", "address"],
  values: [],
};
const getAllEmployees: StaticCall = {
  name: "getAllEmployees",
  selector: "0xe3366fed",
  types: ["bytes4"],
  values: [],
};
const getEmployee: StaticCall = {
  name: "getEmployee",
  selector: "0x32648e09",
  types: ["bytes4", "address"],
  values: [],
};
const payAllEmployees: StaticCall = {
  name: "payAllEmployees",
  selector: "0x809e9ef5",
  types: ["bytes4"],
  values: [],
};
const getBalance: StaticCall = {
  name: "getBalance",
  selector: "0x12065fe0",
  types: ["bytes4"],
  values: [],
};
const getTotalEmployeeCost: StaticCall = {
  name: "getTotalEmployeeCost",
  selector: "0x1e153139",
  types: ["bytes4"],
  values: [],
};

export default {
  createEmployee,
  updateEmployee,
  deleteEmployee,
  getEmployee,
  payAllEmployees,
  getBalance,
  getAllEmployees,
  getTotalEmployeeCost,
};
