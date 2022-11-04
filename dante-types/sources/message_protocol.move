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

    // MessageItem
    struct MessageItem has key, store {
        id: UID,
        name: vector<u8>,
        type: u8,
    }

    //Getter and Setter for `MessageItem`
    public fun item_set_name<T: copy + drop + store>(self: &mut MessageItem, name: vector<u8>) {
        self.name = name;
    }

    public fun item_name<T: copy + drop + store>(self: &MessageItem): vector<u8> {
        self.name
    }

    // public fun item_set_value<T: copy + drop + store>(self: &mut MessageItem, value: T) {
    //     self.value = value;
    // }

    // public fun item_value<T: copy + drop + store>(self: &MessageItem): T {
    //     self.value
    // }
    
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

    fun value_type_judge(item: &MessageItem): bool {
        let x = false;
        if (item.type == Sui_String) {
            x = dynamic_field::exists_with_type<vector<u8>, vector<u8>>(&item.id, b"value");
        };

        x
    }

    // public entry fun message_item_to_rawbytes<T: copy + drop + store>(item: &MessageItem<T>): vector<u8> {
    //     if (item.type == Sui_Address) {
    //         let x = item_value<address>(item);
    //         // address_to_rawbytes(&x)
    //     };

    //     vector<u8>[]
    // }

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

    // #[test]
    // public fun test_bcs() {
    //     let x128: u128 = 0xff223344556677889900112233445566;
    //     let item = create_item(b"Hello Nika", x128);
    //     let item_bytes = number_to_be_rawbytes(&item.value);
    //     assert!(item_bytes == vector<u8>[0xff, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66], 0);
    //     assert!(vector::length(&item_bytes) == 16, 1);
    // }
}

// module dante_types::payload {
//     use sui::object::{Self, ID, UID};

//     struct Payload has key, store {
//         id: UID,
//     }


// }

module dante_types::message_protocol {
    use dante_types::message_item;

    // fun create_payload(): message_item::MessageItem<vector<vector<u8>>> {
    //     message_item::vec_string_create_item(b"Nika", vector<vector<u8>>[vector<u8>[0x11, 0x22]])
    // }

    // #[test]
    // public fun test_creation() {
    //     let x = create_payload();
    //     assert!(message_item::item_value(&x) == vector<vector<u8>>[vector<u8>[0x11, 0x22]], 0);
    // }
}
