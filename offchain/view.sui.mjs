import { JsonRpcProvider, Network } from '@mysten/sui.js';
import {BCS, fromB64, getSuiMoveConfig } from '@mysten/bcs'

const provider = new JsonRpcProvider(Network.DEVNET);
const bcs = new BCS(getSuiMoveConfig());

async function objects_test() {
    const env_object_id = '0x5f397cec72cb413405769953c9c5dc86c2bdab24';
    const sender_object_id = '0x278c32836dda5857aeec557e0b64a94141351cf5';

    const objects_owned_by_env = await provider.getObjectsOwnedByObject(env_object_id);
    // console.log("Objects owned by env: ")
    // console.log(objects_owned_by_env);

    const objects_owned_by_sender = await provider.getObjectsOwnedByObject(sender_object_id);
    // console.log("Objects owned by sender: ")
    // console.log(objects_owned_by_sender);

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
                // It's payload below
                console.log(sentMessage.details.data.fields.data);

                // const msgItems = await provider.getObjectsOwnedByObject(objIDCache.details.data.fields.value[idx2]);
                const msgItemsWrapper = await provider.getObjectsOwnedByObject(sentMessage.details.data.fields.data.fields.id.id);
                // console.log(msgItemsWrapper);
                for (var itemIdx in msgItemsWrapper) {
                    const msgItemsObject = await provider.getObjectsOwnedByObject(msgItemsWrapper[itemIdx].objectId);
                    const msgItems = await provider.getObject(msgItemsObject[0].objectId);
                    // message item
                    console.log(msgItems.details.data.fields);

                    const itemValuesObject = await provider.getObjectsOwnedByObject(msgItems.details.data.fields.id.id);
                    for (var valueIdx in itemValuesObject) {
                        const value = await provider.getObject(itemValuesObject[valueIdx].objectId);
                        console.log(value.details.data.fields);
                        console.log(Buffer.from(fromB64(value.details.data.fields.name)).toString());
                        for (var vecStrIdx in value.details.data.fields.value) {
                            console.log(Buffer.from(fromB64(value.details.data.fields.value[vecStrIdx])).toString());
                        }
                    }
                }
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