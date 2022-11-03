module dante_types::message_protocol {
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

    struct MessageItem<T: copy + drop + store> has copy, drop, store {
        name: vector<u8>,
        type: u8,
        value: T,
    }

    public entry fun string_create_item(name: vector<u8>, value: vector<u8>): MessageItem<vector<u8>>{        
        MessageItem {
            name,
            type: Sui_String,
            value,
        }
    }

    public entry fun u8_create_item(name: vector<u8>, value: u8): MessageItem<u8>{        
        MessageItem {
            name,
            type: Sui_U8,
            value,
        }
    }

    public entry fun u16_create_item(name: vector<u8>, value: u16): MessageItem<u16>{        
        MessageItem {
            name,
            type: Sui_U16,
            value,
        }
    }

    public entry fun u32_create_item(name: vector<u8>, value: u32): MessageItem<u32>{        
        MessageItem {
            name,
            type: Sui_U32,
            value,
        }
    }

    public entry fun u64_create_item(name: vector<u8>, value: u64): MessageItem<u64>{        
        MessageItem {
            name,
            type: Sui_U64,
            value,
        }
    }

    public entry fun u128_create_item(name: vector<u8>, value: u128): MessageItem<u128>{        
        MessageItem {
            name,
            type: Sui_U128,
            value,
        }
    }

    public entry fun vec_string_create_item(name: vector<u8>, value: vector<vector<u8>>): MessageItem<vector<vector<u8>>>{        
        MessageItem {
            name,
            type: Sui_Vec_String,
            value,
        }
    }

     public entry fun vec_u8_create_item(name: vector<u8>, value: vector<u8>): MessageItem<vector<u8>>{        
        MessageItem {
            name,
            type: Sui_Vec_U8,
            value,
        }
    }

    public entry fun vec_u16_create_item(name: vector<u8>, value: vector<u16>): MessageItem<vector<u16>>{        
        MessageItem {
            name,
            type: Sui_Vec_U16,
            value,
        }
    }

    public entry fun vec_u32_create_item(name: vector<u8>, value: vector<u32>): MessageItem<vector<u32>>{        
        MessageItem {
            name,
            type: Sui_Vec_U32,
            value,
        }
    }

    public entry fun vec_u64_create_item(name: vector<u8>, value: vector<u64>): MessageItem<vector<u64>>{        
        MessageItem {
            name,
            type: Sui_Vec_U64,
            value,
        }
    }

    public entry fun vec_u128_create_item(name: vector<u8>, value: vector<u128>): MessageItem<vector<u128>>{        
        MessageItem {
            name,
            type: Sui_Vec_U128,
            value,
        }
    }

    fun number_item_to_be_bytes<T: copy + drop + store>(item: MessageItem<T>): vector<u8> {
        let x = bcs::to_bytes(&item.value);
        vector::reverse<u8>(&mut x);
        x
    }

    #[test]
    public fun test_bcs() {
        let x128: u128 = 0xff223344556677889900112233445566;
        let item = u128_create_item(b"Hello Nika", x128);
        let item_bytes = number_item_to_be_bytes(item);
        // assert!(item_bytes == vector<u8>[0xff, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66], 0);
        assert!(vector::length(&item_bytes) == 16, 1);
    }
}
