import contracts from "./contracts.js";
import { foundry } from "viem/chains";
import setup from "./setup.js";


async function payAllEmployees() {
    const contractDetails = {
        abi: contracts.facet_bank.abi,
        address: contracts.diamond.address,
        functionName: "payAllEmployees",
        chain: foundry,
    };
    const eventDetails = {
        address: contracts.facet_bank_v2.address,
        event: contracts.facet_bank_v2.abi[2],
        onLogs: logs => console.log(logs)
    }

    const unwatch = setup.publicClient.watchEvent(eventDetails)
    const hash = await setup.walletClient.writeContract(contractDetails);
    const receipt = await setup.publicClient.waitForTransactionReceipt({ hash });


    if (receipt.status === 'success') {
        console.log("✅ Payed with success");
    } else {
        console.log("🚨 Payed reverted");
    }
}

export default {
    payAllEmployees
}