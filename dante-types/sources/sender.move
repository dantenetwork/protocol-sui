module dante_types::env_recorder {
    use dante_types::SQoS::SQoS;
    use dante_types::session::Session;
    
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};
    use sui::transfer;
    use sui::dynamic_field;

    use std::bcs;

    friend dante_types::sender;

    // definations
    const CHAIN_NAME: vector<u8> = b"SUI_TESTNET";
    public fun chain_name(): vector<u8> {CHAIN_NAME}

    struct SendOutEnv has key, store {
        id: UID,
        // dynamic field: send out nonce
        // dynamic field: `ProtocolContext`
    }

    // context
    struct ProtocolContext has copy, drop, store {
        id: u128,
        fromChain: vector<u8>,
        sender: vector<u8>,
        signer: vector<u8>,
        sqos: SQoS,
        session: Session,
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// initiallization
    fun init(ctx: &mut TxContext) {
        let son = SendOutEnv {
            id: object::new(ctx),
        };
        transfer::share_object(son);
    }

    // just for test
    #[test_only]
    public(friend) fun test_init(ctx: &mut TxContext) {
        let son = SendOutEnv {
            id: object::new(ctx),
        };
        transfer::share_object(son);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// send out nonce
    /// send id is started from `1`
    public(friend) fun next_send_id(send_out_env: &mut SendOutEnv, toChain: vector<u8>): u128 {
        let nonce: u128;
        if (dynamic_field::exists_with_type<vector<u8>, u128>(&mut send_out_env.id, toChain)) {
            let nonceRef = dynamic_field::borrow_mut<vector<u8>, u128>(&mut send_out_env.id, toChain);
            nonce = *nonceRef;
            *nonceRef = nonce + 1;
        } else {
            nonce = 1;
            dynamic_field::add(&mut send_out_env.id, toChain, (2 as u128));
        };

        nonce
    }

    public fun check_send_id(send_out_env: &SendOutEnv, toChain: vector<u8>): u128 {
        if (dynamic_field::exists_with_type<vector<u8>, u128>(&send_out_env.id, toChain)) {
            *dynamic_field::borrow<vector<u8>, u128>(&send_out_env.id, toChain)
        } else {
            1
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// Context
    public(friend) fun create_context(id: u128,
                                    fromChain: vector<u8>,
                                    sender: address,
                                    signer: address,
                                    sqos: SQoS,
                                    session: Session,): ProtocolContext {
        ProtocolContext {
            id,
            fromChain: fromChain,
            sender: bcs::to_bytes(&sender),
            signer: bcs::to_bytes(&signer),
            sqos: sqos,
            session: session,
        }
    }

    public fun protocol_context_id(protocol_context: &ProtocolContext): u128 {protocol_context.id}
    public fun protocol_context_sqos(protocol_context: &ProtocolContext): SQoS {protocol_context.sqos}
    public fun protocol_context_session(protocol_context: &ProtocolContext): Session {protocol_context.session}
    public fun protocol_context_from_chain(protocol_context: &ProtocolContext): vector<u8> {protocol_context.fromChain}
    public fun protocol_context_sender(protocol_context: &ProtocolContext): vector<u8> {protocol_context.sender}
    public fun protocol_context_signer(protocol_context: &ProtocolContext): vector<u8> {protocol_context.signer}
}

module dante_types::sender {
    use dante_types::message_item::{Self};
    use dante_types::payload::{Self, RawPayload};
    use dante_types::SQoS::{Self, SQoS};
    use dante_types::session::{Self, Session};
    use dante_types::env_recorder::{Self, SendOutEnv, ProtocolContext};
    
    use std::bcs;
    use std::vector;
    use std::option::{Self, Option};

    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::dynamic_field;
    use sui::dynamic_object_field;
    use sui::event;

    //Error
    const E_Invalid_MessageID: u64 = 0;
    

    struct SentMessage has key, store {
        id: UID,
        msgID: u128,
        fromChain: vector<u8>,
        toChain: vector<u8>,

        sqos: SQoS,
        contractName: vector<u8>,
        actionName: vector<u8>,
        data: RawPayload,

        sender: address,
        signer: address,

        session: Session,
    }

    struct EventSentMessage has copy, drop {
        id: ID,
        toChain: vector<u8>,
        msgID: u128,
    }

    struct ProtocolSender has key, store {
        id: UID,
        // toChains: vector<vector<u8>>,
        // dynamic field: map<toChain, vector<ID>>
        // dynamic object field: map<toChain|ID, SentMessage>
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// init
    fun init(ctx: &mut TxContext) {
        let sender = ProtocolSender {
            id: object::new(ctx),
            // toChains: vector::empty<vector<u8>>(),
        };

        transfer::share_object(sender);
    }

    // just for test
    #[test_only]
    fun test_init(ctx: &mut TxContext) {
        let sender = ProtocolSender {
            id: object::new(ctx),
            // toChains: vector::empty<vector<u8>>(),
        };

        transfer::share_object(sender);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    fun raw_send_out_message(msgID: u128,
                            toChain: vector<u8>,
                            sqos: SQoS,
                            contractName: vector<u8>,
                            actionName: vector<u8>,
                            data: RawPayload,
                            session: Session,
                            protocol_sender: &mut ProtocolSender,
                            ctx: &mut TxContext): ProtocolContext {
        let sender = tx_context::sender(ctx);

        let suiUid = object::new(ctx);
        let suiID = object::uid_to_inner(&suiUid);

        let sentMessage = SentMessage {
                                        id: suiUid,
                                        msgID,
                                        fromChain: env_recorder::chain_name(),
                                        toChain,
                                        sqos,
                                        contractName,
                                        actionName,
                                        data,
                                        sender,
                                        signer: sender,
                                        session,
                                    };
        if (dynamic_field::exists_with_type<vector<u8>, vector<ID>>(&protocol_sender.id, toChain)) {
            let sentCache = dynamic_field::borrow_mut<vector<u8>, vector<ID>>(&mut protocol_sender.id, toChain);
            vector::push_back<ID>(sentCache, suiID);
            assert!(msgID == (vector::length(sentCache) as u128), E_Invalid_MessageID);
        } else {
            dynamic_field::add(&mut protocol_sender.id, toChain, vector<ID>[suiID]);
            // vector::push_back(&mut protocol_sender.toChains, toChain);
        };

        let dofKey = toChain;
        vector::append<u8>(&mut dofKey, message_item::number_to_be_rawbytes(&msgID));
        dynamic_object_field::add(&mut protocol_sender.id, dofKey, sentMessage);

        event::emit(EventSentMessage {
            id: suiID,
            toChain,
            msgID,
        });

        env_recorder::create_context(msgID, env_recorder::chain_name(), sender, sender, sqos, session)
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// invocation/message out
    public fun send_message_out(toChain: vector<u8>,
                                    sqos: SQoS,
                                    contractName: vector<u8>,
                                    actionName: vector<u8>,
                                    data: RawPayload, 
                                    send_out_env: &mut SendOutEnv, 
                                    protocol_sender: &mut ProtocolSender,
                                    ctx: &mut TxContext) {
        let msgID = env_recorder::next_send_id(send_out_env, toChain);
        
        let session = session::create_session(msgID,
                                            session::sess_send_msg_out(),
                                            option::none<vector<u8>>(),
                                            option::none<vector<u8>>(),
                                            option::none<vector<u8>>());

        raw_send_out_message(msgID, toChain, sqos, contractName, actionName, data, session, protocol_sender, ctx);                             
    }

    public fun call_out(toChain: vector<u8>,
                                sqos: SQoS,
                                contractName: vector<u8>,
                                actionName: vector<u8>,
                                data: RawPayload,
                                commitment: Option<vector<u8>>, 
                                send_out_env: &mut SendOutEnv, 
                                protocol_sender: &mut ProtocolSender,
                                ctx: &mut TxContext) {
        let msgID = env_recorder::next_send_id(send_out_env, toChain);

        let session = session::create_session(msgID,
                                            session::sess_call_out(),
                                            option::none<vector<u8>>(),
                                            commitment,
                                            option::none<vector<u8>>());
        
        raw_send_out_message(msgID, toChain, sqos, contractName, actionName, data, session, protocol_sender, ctx); 
    }

    public fun response_out(toChain: vector<u8>,
                                sqos: SQoS,
                                contractName: vector<u8>,
                                actionName: vector<u8>,
                                data: RawPayload,
                                answer: Option<vector<u8>>, 
                                protocol_context: ProtocolContext,
                                send_out_env: &mut SendOutEnv, 
                                protocol_sender: &mut ProtocolSender,
                                ctx: &mut TxContext) {

        let msgID = env_recorder::next_send_id(send_out_env, toChain);

        let session = session::create_session(env_recorder::protocol_context_id(&protocol_context),
                                            session::sess_callback(),
                                            option::none<vector<u8>>(),
                                            option::none<vector<u8>>(),
                                            answer);
        
        raw_send_out_message(msgID, toChain, sqos, contractName, actionName, data, session, protocol_sender, ctx); 
    }

    public(friend) fun error_notification(fromChain: vector<u8>, sourceMsgId: u128, send_out_env: &mut SendOutEnv, protocol_sender: &mut ProtocolSender, ctx: &mut TxContext) {
        let msgID = env_recorder::next_send_id(send_out_env, fromChain);

        let session = session::create_session(sourceMsgId,
                                            session::sess_remote_error(),
                                            option::none<vector<u8>>(),
                                            option::none<vector<u8>>(),
                                            option::none<vector<u8>>());
        
        raw_send_out_message(msgID, fromChain, SQoS::create_SQoS(), vector::empty<u8>(), vector::empty<u8>(), payload::create_raw_payload(), session, protocol_sender, ctx); 
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// serialization
    public fun into_raw_bytes(sentMessage: &SentMessage): vector<u8> {
        let output = vector::empty<u8>();

        vector::append(&mut output, message_item::number_to_be_rawbytes(&sentMessage.msgID));
        vector::append(&mut output, sentMessage.fromChain);
        vector::append(&mut output, sentMessage.toChain);

        vector::append(&mut output, SQoS::sqos_to_bytes(&sentMessage.sqos));

        vector::append(&mut output, sentMessage.contractName);
        vector::append(&mut output, sentMessage.actionName);

        vector::append(&mut output, payload::raw_payload_to_rawbytes(&sentMessage.data));

        vector::append(&mut output, message_item::address_to_rawbytes(&sentMessage.sender));
        vector::append(&mut output, message_item::address_to_rawbytes(&sentMessage.signer));

        vector::append(&mut output, session::session_to_rawbytes(&sentMessage.session));

        output
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// entry test
    public entry fun test_send_message_out(send_out_env: &mut SendOutEnv, protocol_sender: &mut ProtocolSender, ctx: &mut TxContext) {
        let toChain: vector<u8> = b"Polkadot";
        let sqos: SQoS = SQoS::create_SQoS();
        let contractName: vector<u8> = vector<u8>[0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08];
        let actionName: vector<u8> =vector<u8>[0x01, 0x02, 0x03, 0x04];
        let data: RawPayload = payload::create_raw_payload();
        let item = message_item::create_raw_item(b"Nika", vector<vector<u8>>[b"Hello", b"Nice Day"]);
        payload::push_back_raw_item(&mut data, item);

        send_message_out(toChain, sqos, contractName, actionName, data, send_out_env, protocol_sender, ctx);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    #[test]
    // address length is 20 bytes
    public fun test_address() {
        let address_bytes = vector<u8>[01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
        let a: address = object::address_from_bytes(address_bytes);
        assert!(bcs::to_bytes(&a) ==  address_bytes, 0);
    }

    #[test]
    public fun test_send_message() {
        use sui::test_scenario;
    
        let alice = @0xACEE;
        // let bob = @0xB0B1;

        let scenario_val = test_scenario::begin(alice);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, alice);
        {
            test_init(test_scenario::ctx(scenario));
            env_recorder::test_init(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, alice);
        {
            let env = test_scenario::take_shared<SendOutEnv>(scenario);
            let protocol_sender = test_scenario::take_shared<ProtocolSender>(scenario);

            test_send_message_out(&mut env, &mut protocol_sender, test_scenario::ctx(scenario));
            assert!(dynamic_field::exists_with_type<vector<u8>, vector<ID>>(&protocol_sender.id, b"Polkadot"), 0);
            test_send_message_out(&mut env, &mut protocol_sender, test_scenario::ctx(scenario));

            // let toChain = b"Polkadot";
            // let sendid1 = env_recorder::next_send_id(&mut env, toChain);
            // let sendid2 = env_recorder::next_send_id(&mut env, toChain);
            // assert!(sendid1 == 1, 1);
            // assert!(sendid2 == 2, 2);

            // std::debug::print(&b"Luckly!");

            test_scenario::return_shared(env);
            test_scenario::return_shared(protocol_sender);
        };

        test_scenario::end(scenario_val);
    }

    const ENCODE_ERROR: u64 = 0;

    #[test]
    public fun test_sent_message_rawbytes() {
        use sui::test_scenario;
        use sui::transfer;
        use sui::ecdsa;

        use std::hash;

        let alice = @0x010203;
        // let bob = @0xB0B1;

        let scenario_val = test_scenario::begin(alice);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, alice);
        {
            let sqos = SQoS::create_SQoS();
            SQoS::add_sqos_item(&mut sqos, SQoS::create_item(SQoS::sqos_challenge(), vector<u8>[1, 2, 3]));

            let data = payload::create_raw_payload();
            payload::push_back_raw_item(&mut data, message_item::create_raw_item(b"Nika", vector<vector<u8>>[b"Hello", b"Nice Day"]));
            payload::push_back_raw_item(&mut data, message_item::create_raw_item(b"Luffy", vector<u128>[73, 37]));

            let sender = test_scenario::sender(scenario);

            let session = session::create_session(1, 3, option::none(), option::some(vector<u8>[49, 49]), option::none());

            let sentMessage = SentMessage {
                                        id: object::new(test_scenario::ctx(scenario)),
                                        msgID: 1,
                                        fromChain: env_recorder::chain_name(),
                                        toChain: b"Polkadot",
                                        sqos,
                                        contractName: vector<u8>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                                        actionName: vector<u8>[0, 0, 0, 0],
                                        data,
                                        sender,
                                        signer: sender,
                                        session,
                                    };

            // std::debug::print(&into_raw_bytes(&sentMessage));

            let except_vec = vector<u8>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 
                                83, 85, 73, 95, 84, 69, 83, 84, 78, 69, 84, 80, 111, 108, 107, 97, 100, 111, 116, 1, 1, 2, 3, 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                                78, 105, 107, 97, 72, 101, 108, 108, 111, 78, 105, 99, 101, 32, 68, 97, 121, 76, 117, 102, 102, 121, 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 
                                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 49, 49];

            assert!(into_raw_bytes(&sentMessage) == except_vec, ENCODE_ERROR);

            let sm_hash_1 = ecdsa::keccak256(&into_raw_bytes(&sentMessage));
            std::debug::print(&sm_hash_1);

            let sm_hash_2 = hash::sha2_256(into_raw_bytes(&sentMessage));
            std::debug::print(&sm_hash_2);

            let sm_hash_3 = hash::sha3_256(into_raw_bytes(&sentMessage));
            std::debug::print(&sm_hash_3);
            
            transfer::transfer(sentMessage, alice);
        };

        test_scenario::end(scenario_val);
    }
}