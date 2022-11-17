import { JsonRpcProvider, Network } from '@mysten/sui.js';
import {BCS, fromB64, getSuiMoveConfig } from '@mysten/bcs'

const provider = new JsonRpcProvider(Network.DEVNET);
const bcs = new BCS(getSuiMoveConfig());

async function objects_test() {
    // const objects = await provider.getObjectsOwnedByAddress(
    //     '0x7f3b0d77188819024ff23080474e10dc18d575da'
    // );

    // console.log(objects);

    const objects_owned_by_env = await provider.getObjectsOwnedByObject("0xf1d088826d781d80ec22736daa943d05e6b35b75");
    console.log("Objects owned by env: ")
    console.log(objects_owned_by_env);

    const objects_owned_by_sender = await provider.getObjectsOwnedByObject("0x970968079e39b6b5f3e1b1e42d7820f4b02637a4");
    console.log("Objects owned by sender: ")
    console.log(objects_owned_by_sender);

    var sentMsg = [];
    for (var idx in objects_owned_by_sender) {
        const sentMsgObj = await provider.getObject(objects_owned_by_sender[idx].objectId);
        console.log(Buffer.from(fromB64(sentMsgObj.details.data.fields.name)).toString());
        console.log(sentMsgObj.details.data.fields.value);
    }
}

async function bcs_test() {
    // console.log(bcs.de(BCS.STRING, fromB64('UG9sa2Fkb3Q=')));
    console.log(Buffer.from(fromB64('UG9sa2Fkb3Q=')).toString());
    console.log(fromB64('UG9sa2Fkb3Q='));

    let ser1 = bcs.ser(BCS.STRING, 'Polkadot').toBytes();
    console.log(ser1);
    console.log(bcs.de(BCS.STRING, ser1));
}

// await bcs_test();
await objects_test();