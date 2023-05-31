import contracts from "./contracts.js";
import { foundry } from "viem/chains";
import { parseAbiItem } from 'viem' 
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
        event: parseAbiItem("event Paid(address indexed employee, uint256 budge)"),
        onLogs: (logs) => console.log(logs)
    }

    let unwatch
    let hash
    let receipt
    try {
        unwatch = setup.publicClient.watchEvent(eventDetails)
        hash = await setup.walletClient.writeContract(contractDetails);
        receipt = await setup.publicClient.waitForTransactionReceipt({ hash });
        if (receipt.status === 'success') {
            console.log("✅ Payed with success");
        } else {
            console.log("🚨 Payed reverted");
        }
    } catch {
        console.log("🚨 Payed reverted");
    }


}

export default {
    payAllEmployees
}