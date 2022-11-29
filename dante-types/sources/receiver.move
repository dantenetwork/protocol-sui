module dante_types::receiver {
    use dante_types::payload::{RawPayload};
    // use dante_types::env_recorder::{ProtocolContext};
    use dante_types::SQoS::{SQoS};
    use dante_types::session::{Session};

    use sui::object::{UID};
    // use sui::tx_context::{Self, TxContext};
    use sui::table;

    // operation as an object
    struct Operation has copy, drop, store {
        // module_name: vector<u8>,
        op_name: vector<u8>,
        // data: RawPayload,
        // dante_ctx: ProtocolContext,
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
    }

    struct ProtocolRecver has key, store {
        id: UID,
        max_recved_id: table::Table<vector<u8>, u128>,          // map<from chain, received message ID>
        message_cache: table::Table<vector<u8>, RecvCache>,     // map<from chain | msgID, RecvCache>
    }

    /////////////////////////////////////////////////////////////////////////
    /// Operation
    // public fun op_module_name(op: &Operation): vector<u8> {op.module_name}
    public fun op_op_name(op: &Operation): vector<u8> {op.op_name}
    // public fun op_data(op: &Operation): RawPayload {op.data}
    // public fun op_dante_ctx(op: &Operation): ProtocolContext {op.dante_ctx}

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
    // public entry fun submit_message(ctx: &mut TxContext) {
    //     let submitter = tx_context::sender(ctx);


    // }

    /////////////////////////////////////////////////////////////////////////
    // private functions
    fun message_verify() {

    }
    
    /////////////////////////////////////////////////////////////////////////
    #[test]
    public fun test_vec_op() {
        let vec1 = vector<u8>[1, 2, 3];
        std::vector::append<u8>(&mut vec1, vector<u8>[17, 18, 19]);
        vec1 = vector<u8>[4, 5, 6];
        std::vector::append<u8>(&mut vec1, vector<u8>[7, 8, 9]);
        assert!(vec1 == vector<u8>[4,5,6,7,8,9], 0);

        let op1 = vector<Operation>[Operation {
            op_name: vec1,
        }];

        assert!(std::vector::borrow<Operation>(&op1, 0).op_name == vector<u8>[4,5,6,7,8,9], 0);

        let op2 = vector<Operation>[Operation {
            op_name: vector<u8>[11, 12, 13, 14,115],
        }];

        op1 = op2;

        assert!(std::vector::borrow<Operation>(&op1, 0).op_name == vector<u8>[11, 12, 13, 14,115], 0);
        assert!(std::vector::borrow<Operation>(&op2, 0).op_name == vector<u8>[11, 12, 13, 14,115], 0);

        op1 = vector<Operation>[];
        assert!(std::vector::is_empty(&op1), 0);
    }
}
