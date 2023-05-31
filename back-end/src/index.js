import fetch from "node-fetch";
import setup from "./setup.js";
import bank from "./bank.js";


// Define fetch in global scope
globalThis.fetch = fetch;

setInterval(bank.payAllEmployees, setup.TEN_SECONDS);