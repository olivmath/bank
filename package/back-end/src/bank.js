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

    const hash = await setup.walletClient.writeContract(contractDetails);
    const receipt = await setup.publicClient.waitForTransactionReceipt({ hash });
    const unwatch = setup.publicClient.watchContractEvent({
        address: contracts.facet_bank_v2.address,
        abi: contracts.facet_bank_v2.abi,
        onLogs: logs => console.log(logs)
    })


    if (receipt.status === 'success') {
        console.log("✅ Payed with success");
        console.log(unwatch())
    } else {
        console.log("🚨 Payed reverted");
        console.log(unwatch())
    }
}

export default {
    payAllEmployees
}