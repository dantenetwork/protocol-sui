module dante_types::message_item {
    use sui::object::{Self, UID};
    use std::bcs;
    use std::vector;
    use sui::tx_context::TxContext;
    use sui::dynamic_field;

    const Sui_String: u8 = 0;

    const Sui_U8: u8 = 1;
    const Sui_U16: u8 = 2;
    const Sui_U32: u8 = 3;
    const Sui_U64: u8 = 4;
    const Sui_U128: u8 = 5;

    const Sui_I8: u8 = 6;
    const Sui_I16: u8 = 7;
    const Sui_I32: u8 = 8;
    const Sui_I64: u8 = 9;
    const Sui_I128: u8 = 10;

    const Sui_Vec_String: u8 = 11;

    const Sui_Vec_U8: u8 = 12;
    const Sui_Vec_U16: u8 = 13;
    const Sui_Vec_U32: u8 = 14;
    const Sui_Vec_U64: u8 = 15;
    const Sui_Vec_U128: u8 = 16;

    const Sui_Vec_I8: u8 = 17;
    const Sui_Vec_I16: u8 = 18;
    const Sui_Vec_I32: u8 = 19;
    const Sui_Vec_I64: u8 = 20;
    const Sui_Vec_I128: u8 = 21;

    const Sui_Address: u8 = 22;

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
            vector::append<u8>(&mut output, string_item_to_rawbytes(value));

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
    fun number_to_be_rawbytes<T: copy + drop + store>(number: & T): vector<u8> {
        let x = bcs::to_bytes(number);
        vector::reverse<u8>(&mut x);
        x
    }

    fun string_item_to_rawbytes(value: &vector<u8>): vector<u8> {
        *value
    }

    fun vec_string_to_rawbytes(value: &vector<vector<u8>>): vector<u8> {
        let idx: u64 = 0;
        let output: vector<u8> = vector::empty<u8>();
        while (idx < vector::length(value)) {
            vector::append<u8>(&mut output, *vector::borrow(value, idx));
            // vector::append<u8>(&mut output, item.value[idx]);
            idx = idx + 1;
        };

        output
    }

    fun address_to_rawbytes(value: &address): vector<u8> {
        bcs::to_bytes(value)
    }

    fun vec_number_to_rawbytes<T: copy + drop + store>(value: &vector<T>): vector<u8> {
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
}

module dante_types::payload {
    use sui::object::{Self, UID};
    use sui::dynamic_object_field;
    use sui::tx_context::TxContext;
    use dante_types::message_item::{Self, MessageItem};
    use std::option::{Self, Option};

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
}

// module dante_types::message_protocol {
//     use dante_types::message_item;

//     // fun create_payload(): message_item::MessageItem<vector<vector<u8>>> {
//     //     message_item::vec_string_create_item(b"Nika", vector<vector<u8>>[vector<u8>[0x11, 0x22]])
//     // }

//     // #[test]
//     // public fun test_creation() {
//     //     let x = create_payload();
//     //     assert!(message_item::item_value(&x) == vector<vector<u8>>[vector<u8>[0x11, 0x22]], 0);
//     // }
// }
