module dante_types::payload {
    // friend dante_types::message_protocol;
    
    use std::bcs;
    use std::vector;

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
    struct MessageItem<T: copy + drop + store> has copy, drop, store {
        name: vector<u8>,
        type: u8,
        value: T,
    }

    //Getter and Setter for `MessageItem`
    public fun item_set_name<T: copy + drop + store>(self: &mut MessageItem<T>, name: vector<u8>) {
        self.name = name;
    }

    public fun item_name<T: copy + drop + store>(self: &MessageItem<T>): vector<u8> {
        self.name
    }

    public fun item_set_value<T: copy + drop + store>(self: &mut MessageItem<T>, value: T) {
        self.value = value;
    }

    public fun item_value<T: copy + drop + store>(self: &MessageItem<T>): T {
        self.value
    }
    
    // Operations for `MessageItem`
    public fun string_create_item(name: vector<u8>, value: vector<u8>): MessageItem<vector<u8>>{        
        MessageItem {
            name,
            type: Sui_String,
            value,
        }
    }

    public fun u8_create_item(name: vector<u8>, value: u8): MessageItem<u8>{        
        MessageItem {
            name,
            type: Sui_U8,
            value,
        }
    }

    public fun u16_create_item(name: vector<u8>, value: u16): MessageItem<u16>{        
        MessageItem {
            name,
            type: Sui_U16,
            value,
        }
    }

    public fun u32_create_item(name: vector<u8>, value: u32): MessageItem<u32>{        
        MessageItem {
            name,
            type: Sui_U32,
            value,
        }
    }

    public fun u64_create_item(name: vector<u8>, value: u64): MessageItem<u64>{        
        MessageItem {
            name,
            type: Sui_U64,
            value,
        }
    }

    public fun u128_create_item(name: vector<u8>, value: u128): MessageItem<u128>{        
        MessageItem {
            name,
            type: Sui_U128,
            value,
        }
    }

    public fun vec_string_create_item(name: vector<u8>, value: vector<vector<u8>>): MessageItem<vector<vector<u8>>>{        
        MessageItem {
            name,
            type: Sui_Vec_String,
            value,
        }
    }

     public fun vec_u8_create_item(name: vector<u8>, value: vector<u8>): MessageItem<vector<u8>>{        
        MessageItem {
            name,
            type: Sui_Vec_U8,
            value,
        }
    }

    public fun vec_u16_create_item(name: vector<u8>, value: vector<u16>): MessageItem<vector<u16>>{        
        MessageItem {
            name,
            type: Sui_Vec_U16,
            value,
        }
    }

    public fun vec_u32_create_item(name: vector<u8>, value: vector<u32>): MessageItem<vector<u32>>{        
        MessageItem {
            name,
            type: Sui_Vec_U32,
            value,
        }
    }

    public fun vec_u64_create_item(name: vector<u8>, value: vector<u64>): MessageItem<vector<u64>>{        
        MessageItem {
            name,
            type: Sui_Vec_U64,
            value,
        }
    }

    public fun vec_u128_create_item(name: vector<u8>, value: vector<u128>): MessageItem<vector<u128>>{        
        MessageItem {
            name,
            type: Sui_Vec_U128,
            value,
        }
    }

    public fun address_create_item(name: vector<u8>, value: address): MessageItem<address> {
        MessageItem {
            name, 
            type: Sui_Address,
            value,
        }
    }

    // public entry fun message_item_to_rawbytes<T: copy + drop + store>(item: &MessageItem<T>): vector<u8> {

    // }

    ///////////////////////////////////////////////////////////////////////////////////////
    /// Private functions
    fun number_to_be_rawbytes<T: copy + drop + store>(number: & T): vector<u8> {
        let x = bcs::to_bytes(number);
        vector::reverse<u8>(&mut x);
        x
    }

    fun string_item_to_rawbytes(item: &MessageItem<vector<u8>>): vector<u8> {
        assert!(item.type == Sui_String, TYPE_ERROR);
        item.value
    }

    fun vec_string_item_to_rawbytes(item: &MessageItem<vector<vector<u8>>>): vector<u8> {
        assert!(item.type == Sui_String, TYPE_ERROR);
        let idx: u64 = 0;
        let output: vector<u8> = vector::empty<u8>();
        while (idx < vector::length(&item.value)) {
            vector::append<u8>(&mut output, *vector::borrow(&item.value, idx));
            // vector::append<u8>(&mut output, item.value[idx]);
            idx = idx + 1;
        };

        output
    }

    fun address_item_to_rawbytes(item: &MessageItem<address>): vector<u8> {
        assert!(item.type == Sui_Address, TYPE_ERROR);
        bcs::to_bytes(&item.value)
    }

    fun number_item_to_rawbytes<T: copy + drop + store>(item: &MessageItem<T>): vector<u8> {
        assert!((item.type >= Sui_U8) && (item.type <= Sui_U128), TYPE_ERROR);
        number_to_be_rawbytes(&item.value)
    }

    fun vec_number_item_to_rawbytes<T: copy + drop + store>(item: &MessageItem<vector<T>>): vector<u8> {
        assert!((item.type >= Sui_Vec_U8) && (item.type <= Sui_Vec_U128), TYPE_ERROR);
        let idx: u64 = 0;
        let output: vector<u8> = vector::empty<u8>();
        while (idx < vector::length(&item.value)) {
            let x = number_to_be_rawbytes(vector::borrow(&item.value, idx));
            vector::append<u8>(&mut output, x);
            // vector::append<u8>(&mut output, item.value[idx]);
            idx = idx + 1;
        };

        output
    }

    #[test]
    public fun test_bcs() {
        let x128: u128 = 0xff223344556677889900112233445566;
        let item = u128_create_item(b"Hello Nika", x128);
        let item_bytes = number_to_be_rawbytes(&item.value);
        assert!(item_bytes == vector<u8>[0xff, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66], 0);
        assert!(vector::length(&item_bytes) == 16, 1);
    }
}

module dante_types::message_protocol {
    use dante_types::payload;

    fun create_payload(): payload::MessageItem<vector<vector<u8>>> {
        payload::vec_string_create_item(b"Nika", vector<vector<u8>>[vector<u8>[0x11, 0x22]])
    }

    #[test]
    public fun test_creation() {
        let x = create_payload();
        assert!(payload::item_value(&x) == vector<vector<u8>>[vector<u8>[0x11, 0x22]], 0);
    }
}
