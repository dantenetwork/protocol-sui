import { JsonRpcProvider, Network, RawSigner, Ed25519Keypair, Secp256k1Keypair, LocalTxnDataSerializer, getExecutionStatus } from '@mysten/sui.js';
import {BCS, fromB64, toB64, getSuiMoveConfig } from '@mysten/bcs'

import fs from 'fs';

import * as SuiTypes from './sui_types.js'

const provider = new JsonRpcProvider(Network.DEVNET);
const bcs = new BCS(getSuiMoveConfig());

const package_id = '0xd9946316f4d7a2828178ac38d5209298b381d893';
const env_object_id = '0x3348b94cb733e60f6e73947854e69a2287d80f46';
const sender_object_id = '0x115f9da0743e35d1fdc3ac53910dcda4e4712f1d';

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/// To be deprecated
// using on-chain objects to record some meta informations to visit SentMessage
async function objects_test() {
    

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
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

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

    const eventQuery = {"MoveEvent": package_id+"::sender::EventSentMessage"};
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

        const sentMessage = await provider.getObject(event_data.id);
        // console.log(sentMessage.details.data.fields);
        console.log(sentMessage.details.data.fields.data.fields.rawItems[0].fields);

        ///////////////////////////////////////////////
        // decode value
        if (sentMessage.details.data.fields.data.fields.rawItems[0].fields.type == 11) {
            let itemVals = sentMessage.details.data.fields.data.fields.rawItems[0].fields.value;
            console.log(itemVals);

            const bcs4value = new BCS({
                vectorType: 'vector<T>',
                addressLength: 20,
                addressEncoding: 'hex'
            });

            const deData = bcs4value.de('vector<vector<u8>>', itemVals, 'base64');
            // console.log(deData);
            for (var valIdx in deData) {
                let val = deData[valIdx];
                console.log(Buffer.from(val).toString());
            }
        }
        ///////////////////////////////////////////////

        const serData = toB64(bcs.ser(ESM_TypeName, event_data).toBytes());
        console.log(bcs.ser(ESM_TypeName, event_data).toString('base64'));
        console.log(serData);
    }
}

async function sui_move_call() {
    // const data = fs.readFileSync('/home/xiyu/.sui/sui_config/sui.keystore', 'base64');
    // console.log(fromB64(data));

    let buf = Buffer.from('d9fb0917e1d83e2d42f14f6ac5588e755901150f0aa0953bbf529752e786f50c', 'hex');
    // console.log(buf);
    const keypair = Secp256k1Keypair.fromSecretKey(buf);
    // console.log(keypair.keypair.publicKey);
    // console.log(keypair.getPublicKey().toBytes());
    // console.log(Buffer.from(keypair.keypair.publicKey).toString('hex'));
    // console.log(fromB64(keypair.getPublicKey().toString()));
    console.log(keypair.getPublicKey().toSuiAddress());
    
    // try {
    //     await provider.requestSuiFromFaucet('0x59ca90e94cb1427c30aca6c44c7ac1bc2e44dc38');
    // } catch (err) {
    //     console.log(err);
    // }
    // return;

    let signer = new RawSigner(keypair, provider);

    const txn = await signer.executeMoveCall({
        packageObjectId: package_id,
        module: 'sender',
        function: 'test_send_message_out',
        typeArguments: [],
        arguments: [env_object_id, sender_object_id],
        gasBudget: 30000,
    });
    console.log(getExecutionStatus(txn));
}

async function bcs_test() {
    // console.log(bcs.de(BCS.STRING, fromB64('UG9sa2Fkb3Q=')));
    // console.log(Buffer.from(fromB64('UG9sa2Fkb3Q=')).toString());
    // console.log(fromB64('UG9sa2Fkb3Q='));

    // let ser1 = bcs.ser(BCS.STRING, 'Polkadot').toBytes();
    // console.log(ser1);
    // console.log(bcs.de(BCS.STRING, ser1));

    const bcs4value = new BCS({
        vectorType: 'vector<vector<u8>>',
        addressLength: 20,
        addressEncoding: 'hex'
    });

    let valBytes = bcs4value.ser('vector<vector<u8>>', [Buffer.from("Hello"), Buffer.from("Nice Day")]);
    // console.log(valBytes.toString('base64'));
    // console.log(valBytes.toBytes());
    // console.log(new Uint8Array(Buffer.from(valBytes.toString('base64'))));
    // return;

    const bcs = new BCS({
        vectorType: 'vector<u8>',
        addressLength: 20,
        addressEncoding: 'hex'
    });

    const RMI_TypeName = 'RawMessageItem';
    bcs.registerStructType(RMI_TypeName, {
        name: BCS.STRING,
        type: BCS.U8,
        value: BCS.STRING
    });

    const rmiData = {
        name: 'Nika',
        type: 11,
        value: Buffer.from(valBytes.toBytes()).toString('base64')
    };

    const serData = bcs.ser(RMI_TypeName, rmiData).toBytes();
    console.log(serData);
    console.log(bcs.ser(RMI_TypeName, rmiData).toString('base64'));

    const deData = bcs.de(RMI_TypeName, serData, 'base64');
    console.log(deData);
    // console.log(bcs4value.de('vector<vector<u8>>', valBytes.toBytes(), 'base64'));
    console.log(bcs4value.de('vector<vector<u8>>', new Uint8Array(Buffer.from(deData.value, 'base64')), 'base64'));
}

async function test_bcs_bcs() {
    const bcs4value = new BCS({
        vectorType: 'vector',
        addressLength: 20,
        addressEncoding: 'hex'
    });

    const serData = bcs.ser(BCS.U128, BigInt('1234567890123456789011223344'));
    console.log(serData.toBytes());

    const deData = bcs.de(BCS.U128, serData.toBytes(), 'base64');
    console.log(deData);

    const serData2 = bcs4value.ser('vector<u128>', ['1234567890123456789011223344', '987654321']);
    console.log(serData2.toBytes());

    const deData2 = bcs4value.de('vector<u128>', serData2.toBytes(), 'base64');
    console.log(deData2);

    const serData3 = bcs4value.ser(BCS.U8, 255);
    console.log(serData3.toBytes());

    const serData4 = bcs.ser('vector<string>', ['Hello', 'Nika']);
    const deData4 = bcs4value.de('vector<string>', serData4.toBytes(), 'base64');
    console.log(deData4);
}

async function test_types_msgItem() {
    const item = new SuiTypes.SuiMessageItem('Nika', SuiTypes.SuiMsgType.suiVecU128, ['1234567890', '987654321']);
    // console.log(item);
    const serBytes = item.en_bcs_bytes();
    console.log(serBytes);
    const deItem = item.de_bcs_bytes(serBytes)
    console.log(deItem);

    console.log(SuiTypes.bcs_value_vec_u128(new Uint8Array(Buffer.from(deItem.value, 'base64'))));
}

async function test_types_SQoSItem() {
    const item = new SuiTypes.SQoSItem(SuiTypes.SQoSType.Challenge, [73, 37]);
    const serBytes = item.en_bcs_bytes();
    console.log(serBytes);

    const deItem = item.de_bcs_bytes(serBytes);
    console.log(deItem);
    console.log(new Uint8Array(Buffer.from(deItem.value, 'base64')));
}

async function test_types_Session() {
    const sess = new SuiTypes.SuiSession('12800000', SuiTypes.SessionType.MessageSend, null, [73, 37], [73, 37]);
    const serBytes = sess.en_bcs_bytes();
    console.log(serBytes);

    const deItem = sess.de_bcs_bytes(serBytes);
    console.log(deItem);
    // console.log(new Uint8Array(Buffer.from(deItem.commitment.some, 'base64')));
    // console.log(new Uint8Array(Buffer.from(deItem.answer.some, 'base64')));
}

// await bcs_test();
// await objects_test();
// await sent_message_event();
// await sui_move_call();

// await test_bcs_bcs();
// await test_types_msgItem();
// await test_types_SQoSItem();
await test_types_Session();
