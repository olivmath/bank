import fetch from 'node-fetch';
import { createPublicClient, createWalletClient, http } from "viem";
import { foundry } from "viem/chains";
import { privateKeyToAccount } from "viem/accounts";
import contracts from "./contracts.js";

// Define fetch in global scope
globalThis.fetch = fetch;

const TEN_SECONDS = 10 * 1000; 
const account = privateKeyToAccount(contracts.CONTROLLER);

// Create a client configuration to avoid repeating it
const clientConfig = {
    chain: foundry,
    transport: http(),
};

const walletClient = createWalletClient({
    ...clientConfig,
    account,
});

const publicClient = createPublicClient(clientConfig);

async function payAllEmployees() {
    const contractDetails = {
        abi: contracts.facet_bank.abi,
        address: contracts.diamond.address,
        functionName: "payAllEmployees",
        chain: foundry,
    };
    
    const hash = await walletClient.writeContract(contractDetails);
    const receipt = await publicClient.waitForTransactionReceipt({ hash });


    if (receipt.status === 'success') {
        console.log("✅ Payed with success");
    } else {
        console.log("🚨 Payed reverted");
    }
}

setInterval(payAllEmployees, TEN_SECONDS);