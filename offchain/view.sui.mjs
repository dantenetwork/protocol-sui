import { JsonRpcProvider, Network } from '@mysten/sui.js';
import {BCS, fromB64, toB64, getSuiMoveConfig } from '@mysten/bcs'

const provider = new JsonRpcProvider(Network.DEVNET);
const bcs = new BCS(getSuiMoveConfig());

// using on-chain objects to record some meta informations to visit SentMessage
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

// using event to visit SentMessage
async function sent_message_event() {
    const bcs = new BCS({
        vectorType: 'vector',
        addressLength: 20,
        addressEncoding: 'hex'
    });

    const ESM_TypeName = 'EventSentMessage';
    bcs.registerStructType(ESM_TypeName, {
        id: BCS.ADDRESS,
        toChain: BCS.STRING,
        msgID: BCS.U128
    });

    // console.log(bcs);

    // const eventQuery = {"MoveModule": {package: "0xb0194cc9a90ba74c533f0663a6d80d1f9d226456", module: 'sender'}};
    // const allEvents = await provider.getEvents(eventQuery);
    // console.log(allEvents.data);
    // for (var idx in allEvents.data) {
    //     // console.log(allEvents.data[idx].event);
    //     if (undefined != allEvents.data[idx].event.moveEvent) {
    //         if (allEvents.data[idx].event.moveEvent.type == '0xb0194cc9a90ba74c533f0663a6d80d1f9d226456::sender::EventSentMessage') {
    //             console.log(fromB64('5PJqo5dOu6V15ShU3lVAQOgq+xaS3V9olVQlDeNnY/s='));
    //             let event_data = bcs.de(ESM_TypeName, allEvents.data[idx].event.moveEvent.bcs, 'base64');
    //             // console.log(event_data);
    //             const sentMessage = await provider.getObject(event_data.id); 
    //             console.log(sentMessage.details.data.fields);
    //         }
    //     }
    // }

    const eventQuery = {"MoveEvent": "0xb0194cc9a90ba74c533f0663a6d80d1f9d226456::sender::EventSentMessage"};
    const sentMsgEvents = await provider.getEvents(eventQuery);
    // console.log(sentMsgEvents);
    for (var idx in sentMsgEvents.data) {
        // console.log(fromB64(sentMsgEvents.data[idx].event.moveEvent.bcs));
        console.log(sentMsgEvents.data[idx].event.moveEvent.bcs);
        let event_data = bcs.de(ESM_TypeName, sentMsgEvents.data[idx].event.moveEvent.bcs, 'base64');
        console.log(event_data);

        if (event_data.msgID == 1) {
            console.log("lucky!");
        }
        // const sentMessage = await provider.getObject(event_data.id);
        // console.log(sentMessage.details.data.fields);

        const serData = toB64(bcs.ser(ESM_TypeName, event_data).toBytes());
        console.log(bcs.ser(ESM_TypeName, event_data).toString('base64'));
        console.log(serData);
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
// await objects_test();
await sent_message_event();