module dante_types::receiver {
    use dante_types::payload::{Self, RawPayload};
    use dante_types::message_item;
    use dante_types::env_recorder::{ProtocolContext};
    use dante_types::SQoS::{Self, SQoS};
    use dante_types::session::{Self, Session};
    use dante_types::env_recorder;

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::table;
    use sui::ecdsa;
    use sui::transfer;

    use std::vector;
    use std::option::{Self, Option};

    // operation as an object
    struct Operation has copy, drop, store {
        // module_name: vector<u8>,
        op_name: vector<u8>,
        data: RawPayload,
        dante_ctx: ProtocolContext,
    }

    struct RecvMessage has copy, drop, store {
        msgID: u128,
        fromChain: vector<u8>,
        toChain: vector<u8>,

        sqos: SQoS,
        contractName: address,   // Target Sui account
        actionName: vector<u8>,     // Target operation name
        data: RawPayload,

        sender: vector<u8>,
        signer: vector<u8>,

        session: Session,

        // message hash. not included in raw bytes
        message_hash: vector<u8>,
    }

    struct MessageCopy has copy, drop, store {
        message: RecvMessage,
        submitters: vector<address>,
        credibility: u64,
    }

    struct RecvCache has copy, drop, store {
        copy_cache: vector<MessageCopy>,
        submission_count: u32,
    }

    struct ProtocolRecver has key, store {
        id: UID,
        max_recved_id: table::Table<vector<u8>, u128>,          // map<from chain, received message ID>
        message_cache: table::Table<vector<u8>, RecvCache>,     // map<from chain | msgID, RecvCache>

        default_copy_count: u32,
    }

    fun init(ctx: &mut TxContext) {
        let recver = ProtocolRecver {
            id: object::new(ctx),
            max_recved_id: table::new(ctx),
            message_cache: table::new(ctx),
            default_copy_count: 1,
        };

        transfer::share_object(recver);
    }

    #[test_only]
    fun test_init(ctx: &mut TxContext) {
        let recver = ProtocolRecver {
            id: object::new(ctx),
            max_recved_id: table::new(ctx),
            message_cache: table::new(ctx),
            default_copy_count: 1,
        };

        transfer::share_object(recver);
    }

    /////////////////////////////////////////////////////////////////////////
    /// Operation
    // public fun op_module_name(op: &Operation): vector<u8> {op.module_name}
    public fun op_op_name(op: &Operation): vector<u8> {op.op_name}
    public fun op_data(op: &Operation): RawPayload {op.data}
    public fun op_dante_ctx(op: &Operation): ProtocolContext {op.dante_ctx}

    /////////////////////////////////////////////////////////////////////////
    /// RecvMessage
    public fun rv_msg_id(rv: &RecvMessage): u128 {rv.msgID}
    public fun rv_from_chain(rv: &RecvMessage): vector<u8> {rv.fromChain}
    public fun rv_to_chain(rv: &RecvMessage): vector<u8> {rv.toChain}
    public fun rv_sqos(rv: &RecvMessage): SQoS {rv.sqos}
    public fun rv_contract_name(rv: &RecvMessage): address {rv.contractName}
    public fun rv_action_name(rv: &RecvMessage): vector<u8> {rv.actionName}
    public fun rv_payload(rv: &RecvMessage): RawPayload {rv.data}
    public fun rv_sender(rv: &RecvMessage): vector<u8> {rv.sender}
    public fun rv_signer(rv: &RecvMessage): vector<u8> {rv.signer}
    public fun rv_session(rv: &RecvMessage): Session {rv.session}
    public fun rv_hash(rv: &RecvMessage): vector<u8> {rv.message_hash}

    // The entry function for off-chain nodes delivering cross-chain message
    public entry fun submit_message(msgID: u128,
                                    fromChain: vector<u8>,
                                    toChain: vector<u8>,
                                    bcs_sqos: vector<vector<u8>>,       // bcs bytes of SQoSItem
                                    contractName: address,
                                    actionName: vector<u8>,
                                    bcs_data: vector<vector<u8>>,       // bcs bytes of MessageItem
                                    sender: vector<u8>,
                                    signer: vector<u8>,
                                    bcs_session: vector<u8>,            // bcs bytes of Session
                                    protocol_recver: &mut ProtocolRecver,
                                    ctx: &mut TxContext) {
        let submitter = tx_context::sender(ctx);

        let cache_id = fromChain;
        vector::append<u8>(&mut cache_id, message_item::number_to_be_rawbytes(&msgID));

        let msg_cache_opt = option::none();

        if (table::contains(&protocol_recver.message_cache, cache_id)) {
            let recv_cache = table::borrow_mut(&mut protocol_recver.message_cache, cache_id);
            if (!check_submitter(recv_cache, &submitter)) {
                let recv_message = create_recv_message(msgID, fromChain, toChain, bcs_sqos, contractName, actionName, bcs_data, sender, signer, bcs_session);
                instert_message_to_cache(recv_cache, recv_message, &submitter);

                msg_cache_opt = option::some(*recv_cache);
            };
        } else {
            let max_id = get_max_id(protocol_recver, fromChain);
            if (msgID == (max_id + 1)) {
                let recv_cache = create_empty_cache();
                let recv_message = create_recv_message(msgID, fromChain, toChain, bcs_sqos, contractName, actionName, bcs_data, sender, signer, bcs_session);
                instert_message_to_cache(&mut recv_cache, recv_message, &submitter);

                increase_recved_id(protocol_recver, fromChain);

                msg_cache_opt = option::some(recv_cache);
            };
        };

        if (option::is_some(&msg_cache_opt)) {
            let cache_ref = option::borrow_mut(&mut msg_cache_opt);
            if (cache_ref.submission_count >= protocol_recver.default_copy_count) {
                let opt_msg = message_verify(cache_ref);
                assert!(option::is_some(&opt_msg), 0);
            }
        }
    }

    public fun into_raw_bytes(recvMessage: &RecvMessage): vector<u8> {
        let output = vector::empty<u8>();

        vector::append(&mut output, message_item::number_to_be_rawbytes(&recvMessage.msgID));
        vector::append(&mut output, recvMessage.fromChain);
        vector::append(&mut output, recvMessage.toChain);

        vector::append(&mut output, SQoS::sqos_to_bytes(&recvMessage.sqos));

        vector::append(&mut output, message_item::address_to_rawbytes(&recvMessage.contractName));
        vector::append(&mut output, recvMessage.actionName);

        vector::append(&mut output, payload::raw_payload_to_rawbytes(&recvMessage.data));

        vector::append(&mut output, recvMessage.sender);
        vector::append(&mut output, recvMessage.signer);

        vector::append(&mut output, session::session_to_rawbytes(&recvMessage.session));

        output
    }

    /////////////////////////////////////////////////////////////////////////
    // private functions
    fun create_recv_message(msgID: u128,
                            fromChain: vector<u8>,
                            toChain: vector<u8>,
                            bcs_sqos: vector<vector<u8>>,       // bcs bytes of SQoSItem
                            contractName: address,
                            actionName: vector<u8>,
                            bcs_data: vector<vector<u8>>,       // bcs bytes of MessageItem
                            sender: vector<u8>,
                            signer: vector<u8>,
                            bcs_session: vector<u8>,            // bcs bytes of Session
                            ): RecvMessage {
        // generate `RecvMessage`
        let sqos = SQoS::create_SQoS();
        let idx = 0;
        while (idx < vector::length(&bcs_sqos)) {
            SQoS::add_sqos_item(&mut sqos, SQoS::de_item_from_bcs(vector::borrow(&bcs_sqos, idx)));  
            idx = idx + 1;
        };

        let payload_data = payload::create_raw_payload();
        idx = 0;
        while (idx < vector::length(&bcs_data)) {
            payload::push_back_raw_item(&mut payload_data, message_item::de_item_from_bcs(vector::borrow(&bcs_data, idx)));
            idx = idx + 1;
        };

        let sess = session::de_item_from_bcs(&bcs_session);
        
        let recv_message = RecvMessage {
            msgID,
            fromChain,
            toChain,
            sqos,
            contractName,
            actionName,
            data: payload_data,
            sender,
            signer,
            session: sess,
            message_hash: vector<u8>[],
        };

        recv_message.message_hash = ecdsa::keccak256(&into_raw_bytes(&recv_message));

        recv_message
    }
    
    fun message_verify(msg_cache: &RecvCache): Option<RecvMessage> {
        // TODO: message verification
        option::some(vector::borrow(&msg_cache.copy_cache, 0).message)
    }

    fun create_empty_cache(): RecvCache {
        RecvCache {
            copy_cache: vector<MessageCopy>[],
            submission_count: 0,
        }
    }

    fun check_submitter(recv_cache: &RecvCache, submitter: &address): bool {
        let idx = 0;
        let exist = false;
        while (idx < vector::length(&recv_cache.copy_cache)) {
            if (check_submitter_in_copy(vector::borrow(&recv_cache.copy_cache, idx), submitter)) {
                exist = true;
                break
            };
            
            idx = idx + 1;
        };

        exist
    }

    fun check_submitter_in_copy(msg_copy: &MessageCopy, submitter: &address): bool {
        let idx = 0;
        let exist = false;
        while (idx < vector::length(&msg_copy.submitters)) {
            if (vector::borrow(&msg_copy.submitters, idx) == submitter) {
                exist = true;
                break
            };
        
            idx = idx + 1;
        };

        exist
    }

    fun instert_message_to_cache(recv_cache: &mut RecvCache, recv_message: RecvMessage, submitter: &address) {
        let idx = 0;
        let found = false;
        while (idx < vector::length(&recv_cache.copy_cache)) {
            if (vector::borrow(&recv_cache.copy_cache, idx).message.message_hash == recv_message.message_hash) {
                let this_copy = vector::borrow_mut(&mut recv_cache.copy_cache, idx);
                vector::push_back(&mut this_copy.submitters, *submitter);
                // TODO: Add credibility later
                found = true;
                break
            };
            idx = idx + 1;
        };

        if (!found) {
            let this_copy = MessageCopy {
                message: recv_message,
                submitters: vector<address>[*submitter],
                credibility: 0,     // TODO: Add credibility later
            };

            vector::push_back(&mut recv_cache.copy_cache, this_copy);
        };

        recv_cache.submission_count = recv_cache.submission_count + 1;
    }

    fun get_max_id(protocol_recver: &ProtocolRecver, fromChain: vector<u8>): u128 {
        if (table::contains(&protocol_recver.max_recved_id, fromChain)) {
            *table::borrow(&protocol_recver.max_recved_id, fromChain)
        } else {
            0
        }
    }

    fun increase_recved_id(protocol_recver: &mut ProtocolRecver, fromChain: vector<u8>) {
        if (table::contains(&protocol_recver.max_recved_id, fromChain)) {
            let recorded_id = table::borrow_mut(&mut protocol_recver.max_recved_id, fromChain);
            if (*recorded_id == env_recorder::max_u128()) {
                *recorded_id = 1;
            } else {
                *recorded_id = *recorded_id + 1;
            }
        } else {
            table::add(&mut protocol_recver.max_recved_id, fromChain, 1);
        };
    }
    
    /////////////////////////////////////////////////////////////////////////
    #[test_only]
    struct TestStruck has copy, drop, store {
        op_name: vector<u8>,
    }

    #[test]
    public fun test_vec_op() {
        let vec1 = vector<u8>[1, 2, 3];
        std::vector::append<u8>(&mut vec1, vector<u8>[17, 18, 19]);
        vec1 = vector<u8>[4, 5, 6];
        std::vector::append<u8>(&mut vec1, vector<u8>[7, 8, 9]);
        assert!(vec1 == vector<u8>[4,5,6,7,8,9], 0);

        let op1 = vector<TestStruck>[TestStruck {
            op_name: vec1,
        }];

        assert!(std::vector::borrow<TestStruck>(&op1, 0).op_name == vector<u8>[4,5,6,7,8,9], 0);

        let op2 = vector<TestStruck>[TestStruck {
            op_name: vector<u8>[11, 12, 13, 14,115],
        }];

        op1 = op2;

        assert!(std::vector::borrow<TestStruck>(&op1, 0).op_name == vector<u8>[11, 12, 13, 14,115], 0);
        assert!(std::vector::borrow<TestStruck>(&op2, 0).op_name == vector<u8>[11, 12, 13, 14,115], 0);

        op1 = vector<TestStruck>[];
        assert!(std::vector::is_empty(&op1), 0);
    }
}
