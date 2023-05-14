import { createPublicClient, createWalletClient, http } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import contracts from "./contracts.js";
import { foundry } from "viem/chains";


foundry.rpcUrls = {
    public: { http: ["http://anvil:8545"] },
    default: { http: ["http://anvil:8545"] },
}


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


export default {
    TEN_SECONDS,
    account,
    walletClient,
    publicClient
}