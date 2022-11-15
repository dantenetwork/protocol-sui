module dante_types::sender {
    use dante_types::payload::Payload;
    use dante_types::SQoS::SQoS;
    use std::bcs;
    use sui::object::{Self};

    struct SentMessage has key, store {
        id: u128,
        fromChain: vector<u8>,
        toChain: vector<u8>,

        sqos: SQoS,
        contractName: vector<u8>,
        actionName: vector<u8>,
        data: Payload,

        sender: address,
    }

    #[test]
    // address length is 20 bytes
    public fun test_address() {
        let address_bytes = vector<u8>[01, 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];
        let a: address = object::address_from_bytes(address_bytes);
        assert!(bcs::to_bytes(&a) ==  address_bytes, 0);
    }
}