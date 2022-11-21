import { JsonRpcProvider, Network } from '@mysten/sui.js';
import {BCS, fromB64, getSuiMoveConfig } from '@mysten/bcs'

const provider = new JsonRpcProvider(Network.DEVNET);
const bcs = new BCS(getSuiMoveConfig());

async function objects_test() {
    // const objects = await provider.getObjectsOwnedByAddress(
    //     '0x7f3b0d77188819024ff23080474e10dc18d575da'
    // );

    // console.log(objects);

    const objects_owned_by_env = await provider.getObjectsOwnedByObject("0x7eda540f83fe90327a03cff9c02cded06e28dfb8");
    console.log("Objects owned by env: ")
    console.log(objects_owned_by_env);

    const objects_owned_by_sender = await provider.getObjectsOwnedByObject("0x2c1596effa775f806111f6b3dead41fcab2e8bed");
    console.log("Objects owned by sender: ")
    console.log(objects_owned_by_sender);

    var sentMsg = [];
    for (var idx in objects_owned_by_sender) {
        if ('0x2::dynamic_field::Field<vector<u8>, vector<0x2::object::ID>>' == objects_owned_by_sender[idx].type) {
            const objIDCache = await provider.getObject(objects_owned_by_sender[idx].objectId);
            console.log(objIDCache.details.data.fields);
            const toChain = Buffer.from(fromB64(objIDCache.details.data.fields.name)).toString();
            // console.log(toChain);
            // console.log(objIDCache.details.data.fields.value.length);
            for (var idx2 in objIDCache.details.data.fields.value) {
                const sentMessage = await provider.getObject(objIDCache.details.data.fields.value[idx2]);
                console.log(sentMessage.details.data.fields.data);
                const items = await provider.getObjectsOwnedByObject(sentMessage.details.data.fields.data.fields.id.id);
            }
        }
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