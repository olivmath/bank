export interface StaticCall {
  name: string;
  selector: string;
  types: string[];
  values: any[];
  params: string[];
}

const createEmployee: StaticCall = {
  name: "createEmployee",
  selector: "0x520a19c0",
  types: ["bytes4", "address", "uint256"],
  values: [],
  params: ["employee", "budge"],
};
const updateEmployee: StaticCall = {
  name: "updateEmployee",
  selector: "0x5e91d8ec",
  types: ["bytes4", "address", "uint256"],
  values: [],
  params: ["employee", "budge"],
};
const deleteEmployee: StaticCall = {
  name: "deleteEmployee",
  selector: "0x6e7c4ab1",
  types: ["bytes4", "address"],
  values: [],
  params: ["employee"],
};
const getAllEmployees: StaticCall = {
  name: "getAllEmployees",
  selector: "0xe3366fed",
  types: ["bytes4"],
  values: [],
  params: [],
};
const getEmployee: StaticCall = {
  name: "getEmployee",
  selector: "0x32648e09",
  types: ["bytes4", "address"],
  values: [],
  params: ["employee"],
};
const payAllEmployees: StaticCall = {
  name: "payAllEmployees",
  selector: "0x809e9ef5",
  types: ["bytes4"],
  values: [],
  params: [],
};
const getBalance: StaticCall = {
  name: "getBalance",
  selector: "0x12065fe0",
  types: ["bytes4"],
  values: [],
  params: [],
};
const getTotalEmployeeCost: StaticCall = {
  name: "getTotalEmployeeCost",
  selector: "0x1e153139",
  types: ["bytes4"],
  values: [],
  params: [],
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
