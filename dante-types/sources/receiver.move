module dante_types::receiver {
    use dante_types::payload::{RawPayload};
    use dante_types::env_recorder::{ProtocolContext};

    // operation as an object
    struct Operation {
        module_name: vector<u8>,
        op_name: vector<u8>,
        data: RawPayload,
        dante_ctx: ProtocolContext,
    }

    public entry fun submit_message() {

    }

    /////////////////////////////////////////////////////////////////////////
    /// private functions
    fun message_verify() {

    }
}