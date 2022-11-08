module dante_types::message_item {
    use sui::object::{Self, UID};
    use std::bcs;
    use std::vector;
    use sui::tx_context::TxContext;
    use sui::dynamic_field;

    const Sui_String: u8 = 0;
    public fun sui_string(): u8 {Sui_String}

    const Sui_U8: u8 = 1;
    public fun sui_u8(): u8 {Sui_U8}
    const Sui_U16: u8 = 2;
    public fun sui_u16(): u8 {Sui_U16}
    const Sui_U32: u8 = 3;
    public fun sui_u32(): u8 {Sui_U32}
    const Sui_U64: u8 = 4;
    public fun sui_u64(): u8 {Sui_U64}
    const Sui_U128: u8 = 5;
    public fun sui_u128(): u8 {Sui_U128}

    const Sui_I8: u8 = 6;
    public fun sui_i8(): u8 {Sui_I8}
    const Sui_I16: u8 = 7;
    public fun sui_i16(): u8 {Sui_I16}
    const Sui_I32: u8 = 8;
    public fun sui_i32(): u8 {Sui_I32}
    const Sui_I64: u8 = 9;
    public fun sui_i64(): u8 {Sui_I64}
    const Sui_I128: u8 = 10;
    public fun sui_i128(): u8 {Sui_I128}

    const Sui_Vec_String: u8 = 11;
    public fun sui_vec_string(): u8 {Sui_Vec_String}

    const Sui_Vec_U8: u8 = 12;
    public fun sui_vec_u8(): u8 {Sui_Vec_U8}
    const Sui_Vec_U16: u8 = 13;
    public fun sui_vec_u16(): u8 {Sui_Vec_U16}
    const Sui_Vec_U32: u8 = 14;
    public fun sui_vec_u32(): u8 {Sui_Vec_U32}
    const Sui_Vec_U64: u8 = 15;
    public fun sui_vec_u64(): u8 {Sui_Vec_U64}
    const Sui_Vec_U128: u8 = 16;
    public fun sui_vec_u128(): u8 {Sui_Vec_U128}

    const Sui_Vec_I8: u8 = 17;
    public fun sui_vec_i8(): u8 {Sui_Vec_I8}
    const Sui_Vec_I16: u8 = 18;
    public fun sui_vec_i16(): u8 {Sui_Vec_I16}
    const Sui_Vec_I32: u8 = 19;
    public fun sui_vec_i32(): u8 {Sui_Vec_I32}
    const Sui_Vec_I64: u8 = 20;
    public fun sui_vec_i64(): u8 {Sui_Vec_I64}
    const Sui_Vec_I128: u8 = 21;
    public fun sui_vec_i128(): u8 {Sui_Vec_I128}

    const Sui_Address: u8 = 22;
    public fun sui_address(): u8 {Sui_Address}

    // Error 
    const TYPE_ERROR: u64 = 0;

    // value name
    const VALUE_NAME: vector<u8> = b"value";

    // MessageItem
    struct MessageItem has key, store {
        id: UID,
        name: vector<u8>,
        type: u8,
    }

    //Getter and Setter for `MessageItem`
    public fun item_set_name(self: &mut MessageItem, name: vector<u8>) {
        self.name = name;
    }

    public fun item_name(self: &MessageItem): vector<u8> {
        self.name
    }

    public fun item_type(self: &MessageItem): u8 {
        self.type
    }

    public fun item_set_value<T: copy + drop + store>(self: &mut MessageItem, value: T) {
        *dynamic_field::borrow_mut<vector<u8>, T>(&mut self.id, b"value") = value;
    }

    public fun item_value<T: copy + drop + store>(self: &MessageItem): T {
        *dynamic_field::borrow<vector<u8>, T>(&self.id, b"value")
    }
    
    // Operations for `MessageItem`
    public fun create_item<T: copy + drop + store>(item_name: vector<u8>, type: u8, value: T, ctx: &mut TxContext): MessageItem{        
        let item = MessageItem {
            id: object::new(ctx),
            name: item_name,
            type,
        };
        dynamic_field::add(&mut item.id, b"value", value);
        assert!(value_type_judge(&item), TYPE_ERROR);
        item
    }

    public fun delete_item(item: MessageItem) {
        let MessageItem {id, name: _, type: _,} = item;
        object::delete(id);
    }

    fun value_type_judge(item: &MessageItem): bool {
        let x = false;
        if (item.type == Sui_String) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<u8>>(&item.id, b"value");
        } else if (item.type == Sui_U8) {
            x = dynamic_field::exists_with_type<vector<u8>, u8>(&item.id, b"value");
        } else if (item.type == Sui_U16) {
            x = dynamic_field::exists_with_type<vector<u8>, u16>(&item.id, b"value");
        } else if (item.type == Sui_U32) {
            x = dynamic_field::exists_with_type<vector<u8>, u32>(&item.id, b"value");
        } else if (item.type == Sui_U64) {
            x = dynamic_field::exists_with_type<vector<u8>, u64>(&item.id, b"value");
        } else if (item.type == Sui_U128) {
            x = dynamic_field::exists_with_type<vector<u8>, u128>(&item.id, b"value");
        } else if (item.type == Sui_Vec_String) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<vector<u8>>>(&item.id, b"value");
        } else if (item.type == Sui_Vec_U8) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<u8>>(&item.id, b"value");
        } else if (item.type == Sui_Vec_U16) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<u16>>(&item.id, b"value");
        } else if (item.type == Sui_Vec_U32) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<u32>>(&item.id, b"value");
        } else if (item.type == Sui_Vec_U64) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<u64>>(&item.id, b"value");
        } else if (item.type == Sui_Vec_U128) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<u128>>(&item.id, b"value");
        } else if (item.type == Sui_Address) {
            x = dynamic_field::exists_with_type<vector<u8>, address>(&item.id, b"value");
        };

        x
    }

    public fun message_item_to_rawbytes(item: &MessageItem): vector<u8> {
        let output = vector::empty<u8>();
        vector::append<u8>(&mut output, item.name);
        vector::push_back<u8>(&mut output, item.type);

        if (item.type == Sui_String) {
            let value = dynamic_field::borrow<vector<u8>, vector<u8>>(&item.id, b"value");
            vector::append<u8>(&mut output, string_to_rawbytes(value));

        } else if (item.type == Sui_U8) {
            let value = dynamic_field::borrow<vector<u8>, u8>(&item.id, b"value");
            vector::push_back<u8>(&mut output, *value);

        } else if (item.type == Sui_U16) {
            let value = dynamic_field::borrow<vector<u8>, u16>(&item.id, b"value");
            vector::append<u8>(&mut output, number_to_be_rawbytes(value));

        } else if (item.type == Sui_U32) {
            let value = dynamic_field::borrow<vector<u8>, u32>(&item.id, b"value");
            vector::append<u8>(&mut output, number_to_be_rawbytes(value));

        } else if (item.type == Sui_U64) {
            let value = dynamic_field::borrow<vector<u8>, u64>(&item.id, b"value");
            vector::append<u8>(&mut output, number_to_be_rawbytes(value));

        } else if (item.type == Sui_U128) {
            let value = dynamic_field::borrow<vector<u8>, u128>(&item.id, b"value");
            vector::append<u8>(&mut output, number_to_be_rawbytes(value));

        } else if (item.type == Sui_Vec_String) {
            let value = dynamic_field::borrow<vector<u8>, vector<vector<u8>>>(&item.id, b"value");
            vector::append<u8>(&mut output, vec_string_to_rawbytes(value));

        } else if (item.type == Sui_Vec_U8) {
            let value = dynamic_field::borrow<vector<u8>, vector<u8>>(&item.id, b"value");
            vector::append<u8>(&mut output, *value);

        } else if (item.type == Sui_Vec_U16) {
            let value = dynamic_field::borrow<vector<u8>, vector<u16>>(&item.id, b"value");
            vector::append<u8>(&mut output, vec_number_to_rawbytes(value));

        } else if (item.type == Sui_Vec_U32) {
            let value = dynamic_field::borrow<vector<u8>, vector<u32>>(&item.id, b"value");
            vector::append<u8>(&mut output, vec_number_to_rawbytes(value));

        } else if (item.type == Sui_Vec_U64) {
            let value = dynamic_field::borrow<vector<u8>, vector<u64>>(&item.id, b"value");
            vector::append<u8>(&mut output, vec_number_to_rawbytes(value));

        } else if (item.type == Sui_Vec_U128) {
            let value = dynamic_field::borrow<vector<u8>, vector<u128>>(&item.id, b"value");
            vector::append<u8>(&mut output, vec_number_to_rawbytes(value));

        } else if (item.type == Sui_Address) {
            let value = dynamic_field::borrow<vector<u8>, address>(&item.id, b"value");
            vector::append<u8>(&mut output, address_to_rawbytes(value));
        };

        output
    }

    ///////////////////////////////////////////////////////////////////////////////////////
    /// Private functions
    public fun number_to_be_rawbytes<T: copy + drop + store>(number: & T): vector<u8> {
        let x = bcs::to_bytes(number);
        vector::reverse<u8>(&mut x);
        x
    }

    public fun string_to_rawbytes(value: &vector<u8>): vector<u8> {
        *value
    }

    public fun vec_string_to_rawbytes(value: &vector<vector<u8>>): vector<u8> {
        let idx: u64 = 0;
        let output: vector<u8> = vector::empty<u8>();
        while (idx < vector::length(value)) {
            vector::append<u8>(&mut output, *vector::borrow(value, idx));
            // vector::append<u8>(&mut output, item.value[idx]);
            idx = idx + 1;
        };

        output
    }

    public fun address_to_rawbytes(value: &address): vector<u8> {
        bcs::to_bytes(value)
    }

    public fun vec_number_to_rawbytes<T: copy + drop + store>(value: &vector<T>): vector<u8> {
        let idx: u64 = 0;
        let output: vector<u8> = vector::empty<u8>();
        while (idx < vector::length(value)) {
            let x = number_to_be_rawbytes(vector::borrow(value, idx));
            vector::append<u8>(&mut output, x);
            // vector::append<u8>(&mut output, item.value[idx]);
            idx = idx + 1;
        };

        output
    }

    #[test]
    public fun test_item_to_bytes() {
        use sui::test_scenario;

        let owner = @0xCAFE;

        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);
        {
            let x128: u128 = 0xff223344556677889900112233445566;
            let item = create_item(b"Hello Nika", Sui_U128, x128, test_scenario::ctx(scenario));
            let item_bytes = message_item_to_rawbytes(&item);
            let expectBytes = b"Hello Nika";
            vector::append<u8>(&mut expectBytes, vector<u8>[Sui_U128, 0xff, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66]);
            assert!(item_bytes == expectBytes, 0);
            // assert!(vector::length(&item_bytes) == 16, 1);
            delete_item(item);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    public fun test_be_number() {
        let x128: u128 = 0x110022;
        let x128_be_bytes = number_to_be_rawbytes(&x128);
        assert!(x128_be_bytes == vector<u8>[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x22], TYPE_ERROR);

        let x32: u32 = 0x112233;
        let x32_be_bytes = number_to_be_rawbytes(&x32);
        assert!(x32_be_bytes == vector<u8>[0x00, 0x11, 0x22, 0x33], TYPE_ERROR);
    }
}

module dante_types::payload {
    use sui::object::{Self, UID};
    use sui::dynamic_object_field;
    use sui::tx_context::TxContext;
    use dante_types::message_item::{Self, MessageItem};
    use std::option::{Self, Option};
    use std::vector;

    // Error defination
    const NOT_Empty_OBJECT: u64 = 0;

    struct Payload has key, store {
        id: UID,
        
        // store current item size
        size: u64,
    }

    public fun create_payload(ctx: &mut TxContext): Payload {
        Payload {
            id: object::new(ctx),
            size: 0,
        }
    }

    fun delete_last_item(payload: &mut Payload) {
        let itemOpt = pop_back_item(payload);
        if (option::is_some(&itemOpt)) {
            let item = option::extract(&mut itemOpt);
            message_item::delete_item(item);
        };

        option::destroy_none(itemOpt);
    }

    public fun delete_payload(payload: Payload) {
        while (payload.size > 0) {
            delete_last_item(&mut payload);
        };

        let Payload {id, size} = payload;
        assert!(size == 0, NOT_Empty_OBJECT);
        object::delete(id);
    }

    //Getter and Setter for `MessageItem`
    public fun payload_size(payload: &Payload): u64 {
        payload.size
    }

    // serialization
    public fun payload_to_rawbytes(payload: &Payload): vector<u8> {
        let output = vector::empty<u8>();

        let idx: u64 = 0;
        while (idx < payload.size) {
            let itemRef = dynamic_object_field::borrow<u64, message_item::MessageItem>(&payload.id, idx);
            vector::append<u8>(&mut output, message_item::message_item_to_rawbytes(itemRef));
            idx = idx + 1;
        };

        output
    }

    ////////////////////////////////////////////////////////////////////////////
    public fun push_back_item(payload: &mut Payload, item: MessageItem) {
        dynamic_object_field::add(&mut payload.id, payload.size, item);
        payload.size = payload.size + 1;
    }

    public fun pop_back_item(payload: &mut Payload): Option<MessageItem>{
        let output = option::none();

        if (payload.size > 0) {
            let item = dynamic_object_field::remove<u64, MessageItem>(&mut payload.id, payload.size - 1);
            // message_item::delete_item(item);
            payload.size = payload.size - 1;
            option::fill<MessageItem>(&mut output, item);
        };

        output
    }

    #[test]
    public fun test_payload() {
        use sui::test_scenario;

        let owner = @0xCAFE;

        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);
        {
            let x128: u128 = 0xff223344556677889900112233445566;
            let item = message_item::create_item(b"Hello Nika", message_item::sui_u128(), x128, test_scenario::ctx(scenario));
            let payload = create_payload(test_scenario::ctx(scenario));
            push_back_item(&mut payload, item);

            let payloadBytes = payload_to_rawbytes(&payload);

            let expectBytes = b"Hello Nika";
            vector::append<u8>(&mut expectBytes, vector<u8>[message_item::sui_u128(), 0xff, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66]);
            assert!(payloadBytes == expectBytes, 0);
            // assert!(vector::length(&item_bytes) == 16, 1);
            delete_payload(payload);
        };

        test_scenario::end(scenario_val);
    }
}

module dante_types::session {
    use std::option::{Self, Option}; 
    use std::vector;
    use dante_types::message_item;

    const Undefined: u8 = 0;
    public fun sess_undefined(): u8 {Undefined}
    const Send_Msg_Out: u8 = 1;
    public fun sess_send_msg_out(): u8 {Send_Msg_Out}
    const Call_Out: u8 = 2;
    public fun sess_call_out(): u8 {Call_Out}
    const CallBack: u8 = 3;
    public fun sess_callback(): u8 {CallBack}
    const Local_Error: u8 = 104;
    public fun sess_local_error():u8 {Local_Error}
    const Remote_Error: u8 = 105;
    public fun sess_remote_error(): u8 {Remote_Error}

    // Error
    const TYPE_ERROR: u64 = 0;


    struct Session has copy, drop, store {
        id: u128,
        type: u8,
        callback: Option<vector<u8>>,
        commitment: Option<vector<u8>>,
        answer: Option<vector<u8>>,
    }

    public fun create_session(id: u128,
                            type: u8,
                            callback: Option<vector<u8>>,
                            commitment: Option<vector<u8>>,
                            answer: Option<vector<u8>>): Session {
        assert!((Undefined == type) || 
                (Send_Msg_Out == type) || 
                (Call_Out == type) || 
                (CallBack == type) || 
                (Local_Error == type) || 
                (Remote_Error == type), TYPE_ERROR);
        
        Session {
            id,
            type,
            callback,
            commitment,
            answer,
        }
    }

    // Getters and Setters
    public fun session_id(session: &Session): u128 {session.id}
    public fun session_type(session: &Session): u8 {session.type}
    public fun session_callback(session: &Session): Option<vector<u8>> {session.callback}
    public fun session_commitment(session: &Session): Option<vector<u8>> {session.commitment}
    public fun session_answer(session: &Session): Option<vector<u8>> {session.answer}

    // Serialization
    public fun session_to_rawbytes(session: &Session): vector<u8> {
        let output = vector::empty<u8>();
        vector::append<u8>(&mut output, message_item::number_to_be_rawbytes(&session.id));
        vector::append<u8>(&mut output, message_item::number_to_be_rawbytes(&session.type));
        if (option::is_some<vector<u8>>(&session.callback)) {
            let cbVec = *option::borrow(&session.callback);
            vector::append<u8>(&mut output, cbVec);
        };

        if (option::is_some<vector<u8>>(&session.commitment)) {
            let ctVec = *option::borrow(&session.commitment);
            vector::append<u8>(&mut output, ctVec);
        };

        if (option::is_some<vector<u8>>(&session.answer)) {
            let anVec = *option::borrow(&session.answer);
            vector::append<u8>(&mut output, anVec);
        };

        output
    }

    ///////////////////////////////////////////////////////////////////////////////////////////
    #[test]
    public fun test_create_session() {
        let callback = option::some(vector<u8>[0x11, 0x22, 0x33, 0x44]);
        let commitment: Option<vector<u8>> = option::none();
        let answer: Option<vector<u8>> = option::none();

        let sess = create_session(1, 0, callback, commitment, answer);
        let rawData = session_to_rawbytes(&sess);
        let vecData = message_item::number_to_be_rawbytes(&sess.id);
        vector::append<u8>(&mut vecData, message_item::number_to_be_rawbytes(&sess.type));
        vector::append<u8>(&mut vecData, vector<u8>[0x11, 0x22, 0x33, 0x44]);

        assert!(rawData == vecData, TYPE_ERROR);
    }
}

module dante_types::SQoS {
    // use std::vector;

    const Reveal: u8 = 0;
    public fun sqos_reveal(): u8 {Reveal}
    const Challenge: u8 = 1;
    public fun sqos_challenge(): u8 {Challenge}
    const Threshold: u8 = 2;
    public fun sqos_threshold(): u8 {Threshold}
    const Priority: u8 = 3;
    public fun sqos_priority(): u8 {Priority}
    const ExceptionRollback: u8 = 4;
    public fun sqos_exceptionRollback(): u8 {ExceptionRollback}
    const SelectionDelay: u8 = 5;
    public fun ssqos_electionDelay(): u8 {SelectionDelay}
    const Anonymous: u8 = 6;
    public fun sqos_anonymous(): u8 {Anonymous}
    const Identity: u8 = 7;
    public fun sqos_identity(): u8 {Identity}
    const Isolation: u8 = 8;
    public fun sqos_isolation(): u8 {Isolation}
    const CrossVerify: u8 = 9;
    public fun sqos_crossVerify(): u8 {CrossVerify}

    struct SQoSItem {
        t: u8,
        v: vector<u8>,
    }
}
