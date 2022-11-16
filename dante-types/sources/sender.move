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
        // dynamic field: context(TODO)
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
            dynamic_field::add(&mut send_out_env.id, toChain, 2);
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
    use dante_types::payload::{Self, Payload};
    use dante_types::SQoS::{Self, SQoS};
    use dante_types::session::{Self, Session};
    use dante_types::env_recorder::{Self, SendOutEnv, ProtocolContext};
    
    use std::bcs;
    use std::vector;
    use std::option::{Self, Option};

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::dynamic_field;

    //Error
    const E_Invalid_MessageID: u64 = 0;
    

    struct SentMessage has store {
        id: u128,
        fromChain: vector<u8>,
        toChain: vector<u8>,

        sqos: SQoS,
        contractName: vector<u8>,
        actionName: vector<u8>,
        data: Payload,

        sender: address,
        signer: address,

        session: Session,
    }

    struct ProtocolSender has key, store {
        id: UID,
        toChains: vector<vector<u8>>,
        // dynamic field: 
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// init
    fun init(ctx: &mut TxContext) {
        let sender = ProtocolSender {
            id: object::new(ctx),
            toChains: vector::empty<vector<u8>>(),
        };

        transfer::share_object(sender);
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    fun raw_send_out_message(msgID: u128,
                            toChain: vector<u8>,
                            sqos: SQoS,
                            contractName: vector<u8>,
                            actionName: vector<u8>,
                            data: Payload,
                            session: Session,
                            protocol_sender: &mut ProtocolSender,
                            ctx: &mut TxContext): ProtocolContext {
        let sender = tx_context::sender(ctx);

        let sentMessage = SentMessage {
                                        id: msgID,
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
        if (dynamic_field::exists_with_type<vector<u8>, vector<SentMessage>>(&protocol_sender.id, toChain)) {
            let sentCache = dynamic_field::borrow_mut<vector<u8>, vector<SentMessage>>(&mut protocol_sender.id, toChain);
            vector::push_back<SentMessage>(sentCache, sentMessage);
            assert!(msgID == (vector::length(sentCache) as u128), E_Invalid_MessageID);
        } else {
            dynamic_field::add(&mut protocol_sender.id, toChain, vector<SentMessage>[sentMessage]);
        };

        env_recorder::create_context(msgID, env_recorder::chain_name(), sender, sender, sqos, session)
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    /// invocation/message out
    public entry fun send_message_out(toChain: vector<u8>,
                                    sqos: SQoS,
                                    contractName: vector<u8>,
                                    actionName: vector<u8>,
                                    data: Payload, 
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

    public entry fun call_out(toChain: vector<u8>,
                                sqos: SQoS,
                                contractName: vector<u8>,
                                actionName: vector<u8>,
                                data: Payload,
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

    public entry fun response_out(toChain: vector<u8>,
                                sqos: SQoS,
                                contractName: vector<u8>,
                                actionName: vector<u8>,
                                data: Payload,
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
        
        raw_send_out_message(msgID, fromChain, SQoS::create_SQoS(), vector::empty<u8>(), vector::empty<u8>(), payload::create_payload(ctx), session, protocol_sender, ctx); 
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////
    #[test]
    // address length is 20 bytes
    public fun test_address() {
        let address_bytes = vector<u8>[01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
        let a: address = object::address_from_bytes(address_bytes);
        assert!(bcs::to_bytes(&a) ==  address_bytes, 0);
    }
}