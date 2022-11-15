module dante_types::env_recorder {
    use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};
    use sui::transfer;
    use sui::dynamic_field;

    friend dante_types::sender;

    struct SendOutEnv has key, store {
        id: UID,
        // dynamic field: send out nonce
        // dynamic field: context(TODO)
    }

    fun init(ctx: &mut TxContext) {
        let son = SendOutEnv {
            id: object::new(ctx),
        };
        transfer::share_object(son);
    }

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
}

module dante_types::sender {
    use dante_types::payload::Payload;
    use dante_types::SQoS::SQoS;
    use dante_types::session::Session;
    use dante_types::env_recorder::{Self, SendOutEnv};
    use std::bcs;
    use sui::object::{Self};

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

    public fun create_sent_message(send_out_env: &mut SendOutEnv,
                                    toChain: vector<u8>,
                                    sqos: SQoS,
                                    contractName: vector<u8>,
                                    actionName: vector<u8>,
                                    data: Payload,
                                    sender: address,
                                    signer: address,
                                    session: Session): SentMessage {
        SentMessage {
            id: env_recorder::next_send_id(send_out_env, toChain),
            fromChain: b"SUI_TESTNET",
            toChain,
            sqos,
            contractName,
            actionName,
            data,
            sender,
            signer,
            session,
        }
    }

    #[test]
    // address length is 20 bytes
    public fun test_address() {
        let address_bytes = vector<u8>[01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
        let a: address = object::address_from_bytes(address_bytes);
        assert!(bcs::to_bytes(&a) ==  address_bytes, 0);
    }
}