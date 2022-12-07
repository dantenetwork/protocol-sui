"use strict";
exports.__esModule = true;
exports.SuiRecvMessage = exports.SuiSession = exports.SessionType = exports.SuiSQoSItem = exports.SuiSQoSType = exports.SuiMessageItem = exports.bcs_value = exports.bcs_value_vec_u128 = exports.SuiMsgType = void 0;
var bcs_1 = require("@mysten/bcs");
var SuiMsgType;
(function (SuiMsgType) {
    SuiMsgType[SuiMsgType["suiString"] = 0] = "suiString";
    SuiMsgType[SuiMsgType["suiU8"] = 1] = "suiU8";
    // suiU16 = 2,
    // suiU32 = 3,
    SuiMsgType[SuiMsgType["suiU64"] = 4] = "suiU64";
    SuiMsgType[SuiMsgType["suiU128"] = 5] = "suiU128";
    // suiI8 = 6,
    // suiI16 = 7,
    // suiI32 = 8,
    // suiI64 = 9,
    // suiI128 = 10,
    SuiMsgType[SuiMsgType["suiVecString"] = 11] = "suiVecString";
    // suiVecU8 = 12,
    // suiVecU16 = 13,
    // suiVecU32 = 14,
    SuiMsgType[SuiMsgType["suiVecU64"] = 15] = "suiVecU64";
    SuiMsgType[SuiMsgType["suiVecU128"] = 16] = "suiVecU128";
    // suiVecI8 = 17,
    // suiVecI16 = 18,
    // suiVecI32 = 19,
    // suiVecI64 = 20,
    // suiVecI128 = 21,
    SuiMsgType[SuiMsgType["suiAddress"] = 22] = "suiAddress";
})(SuiMsgType = exports.SuiMsgType || (exports.SuiMsgType = {}));
;
var bcs4value = new bcs_1.BCS((0, bcs_1.getSuiMoveConfig)());
function string_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(bcs_1.BCS.STRING, value);
}
function u8_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(bcs_1.BCS.U8, value);
}
function u64_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(bcs_1.BCS.U64, value);
}
function u128_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(bcs_1.BCS.U128, value);
}
function vec_string_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser('vector<string>', value);
}
function vec_u64_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser('vector<u64>', value);
}
function vec_u128_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser('vector<u128>', value);
}
function bcs_value_vec_u128(bcsBytes) {
    return bcs4value.de('vector<u128>', bcsBytes, 'base64');
}
exports.bcs_value_vec_u128 = bcs_value_vec_u128;
function address_bcs_value(value) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(bcs_1.BCS.ADDRESS, value);
}
function bcs_value(type, value) {
    switch (type) {
        case SuiMsgType.suiString: {
            return string_bcs_value(value);
            break;
        }
        case SuiMsgType.suiU8: {
            return u8_bcs_value(value);
            break;
        }
        case SuiMsgType.suiU64: {
            return u64_bcs_value(value);
            break;
        }
        case SuiMsgType.suiU128: {
            return u128_bcs_value(value);
            break;
        }
        case SuiMsgType.suiVecString: {
            return vec_string_bcs_value(value);
            break;
        }
        case SuiMsgType.suiVecU64: {
            return vec_u64_bcs_value(value);
            break;
        }
        case SuiMsgType.suiVecU128: {
            return vec_u128_bcs_value(value);
            break;
        }
        case SuiMsgType.suiAddress: {
            return address_bcs_value(value);
            break;
        }
        default:
            console.log("Sorry, we are out of ".concat(type, "."));
    }
}
exports.bcs_value = bcs_value;
var SuiMessageItem = /** @class */ (function () {
    function SuiMessageItem(name, type, value) {
        var _a;
        this.name = name;
        this.type = type;
        this.value = (_a = bcs_value(type, value)) === null || _a === void 0 ? void 0 : _a.toBytes();
        this.bcs = new bcs_1.BCS((0, bcs_1.getSuiMoveConfig)());
        this.RMI_TypeName = 'RawMessageItem';
        this.bcs.registerStructType(this.RMI_TypeName, {
            name: bcs_1.BCS.STRING,
            type: bcs_1.BCS.U8,
            value: bcs_1.BCS.STRING
        });
    }
    SuiMessageItem.prototype.en_bcs_bytes = function () {
        if (this.value != undefined) {
            return this.bcs.ser(this.RMI_TypeName, {
                name: this.name,
                type: this.type,
                value: Buffer.from(this.value).toString('base64')
            }).toBytes();
        }
    };
    SuiMessageItem.prototype.de_bcs_bytes = function (bcs_bytes) {
        return this.bcs.de(this.RMI_TypeName, bcs_bytes, 'base64');
    };
    return SuiMessageItem;
}());
exports.SuiMessageItem = SuiMessageItem;
var SuiSQoSType;
(function (SuiSQoSType) {
    SuiSQoSType[SuiSQoSType["Reveal"] = 0] = "Reveal";
    SuiSQoSType[SuiSQoSType["Challenge"] = 1] = "Challenge";
    SuiSQoSType[SuiSQoSType["Threshold"] = 2] = "Threshold";
    SuiSQoSType[SuiSQoSType["Priority"] = 3] = "Priority";
    SuiSQoSType[SuiSQoSType["ExceptionRollback"] = 4] = "ExceptionRollback";
    SuiSQoSType[SuiSQoSType["SelectionDelay"] = 5] = "SelectionDelay";
    SuiSQoSType[SuiSQoSType["Anonymous"] = 6] = "Anonymous";
    SuiSQoSType[SuiSQoSType["Identity"] = 7] = "Identity";
    SuiSQoSType[SuiSQoSType["Isolation"] = 8] = "Isolation";
    SuiSQoSType[SuiSQoSType["CrossVerify"] = 9] = "CrossVerify";
})(SuiSQoSType = exports.SuiSQoSType || (exports.SuiSQoSType = {}));
var SuiSQoSItem = /** @class */ (function () {
    function SuiSQoSItem(t, v) {
        this.t = t;
        this.v = v;
        this.RSI_TypeName = 'RawSQoSItem';
        this.bcs = new bcs_1.BCS((0, bcs_1.getSuiMoveConfig)());
        this.bcs.registerStructType(this.RSI_TypeName, {
            type: bcs_1.BCS.U8,
            value: bcs_1.BCS.STRING
        });
    }
    SuiSQoSItem.prototype.en_bcs_bytes = function () {
        return this.bcs.ser(this.RSI_TypeName, {
            type: this.t,
            value: Buffer.from(this.v).toString('base64')
        }).toBytes();
    };
    SuiSQoSItem.prototype.de_bcs_bytes = function (bcs_bytes) {
        return this.bcs.de(this.RSI_TypeName, bcs_bytes, 'base64');
    };
    return SuiSQoSItem;
}());
exports.SuiSQoSItem = SuiSQoSItem;
var SessionType;
(function (SessionType) {
    SessionType[SessionType["MessageSend"] = 1] = "MessageSend";
    SessionType[SessionType["CallOut"] = 2] = "CallOut";
    SessionType[SessionType["Callback"] = 3] = "Callback";
    SessionType[SessionType["LocolErr"] = 104] = "LocolErr";
    SessionType[SessionType["RemoteErr"] = 105] = "RemoteErr";
})(SessionType = exports.SessionType || (exports.SessionType = {}));
var SuiSession = /** @class */ (function () {
    // constructor(id: string, type: SessionType, 
    //             callback: Uint8Array|null = null, 
    //             commitment: Uint8Array|null = null,
    //             answer: Uint8Array|null = null) {
    //     this.id = id;
    //     this.type = type;
    //     this.callback = (callback == null)? {'none': null}: {'some': Buffer.from(callback).toString('base64')};
    //     this.commitment = (commitment == null)? {'none': null}: {'some': Buffer.from(commitment).toString('base64')};;
    //     this.answer = (answer == null)? {'none': null}: {'some': Buffer.from(answer).toString('base64')};;
    //     this.RSess_TypeName = 'RawSession';
    //     this.bcs = new BCS(getSuiMoveConfig());
    //     this.bcs.registerEnumType('Option<vector<u8>>', {
    //         some: BCS.STRING,
    //         none: null
    //     });
    //     this.bcs.registerStructType(this.RSess_TypeName, {
    //         id: BCS.U128,
    //         type: BCS.U8,
    //         callback: 'Option<vector<u8>>',
    //         commitment: 'Option<vector<u8>>',
    //         answer: 'Option<vector<u8>>'
    //     });
    // }
    function SuiSession(id, type, callback, commitment, answer) {
        if (callback === void 0) { callback = null; }
        if (commitment === void 0) { commitment = null; }
        if (answer === void 0) { answer = null; }
        this.id = id;
        this.type = type;
        this.callback = (callback == null) ? [] : [callback];
        this.commitment = (commitment == null) ? [] : [commitment];
        this.answer = (answer == null) ? [] : [answer];
        this.RSess_TypeName = 'RawSession';
        this.bcs = new bcs_1.BCS((0, bcs_1.getSuiMoveConfig)());
        this.bcs.registerStructType('RawSession', {
            id: bcs_1.BCS.U128,
            type: bcs_1.BCS.U8,
            callback: 'vector<vector<u8>>',
            commitment: 'vector<vector<u8>>',
            answer: 'vector<vector<u8>>'
        });
    }
    SuiSession.prototype.en_bcs_bytes = function () {
        return this.bcs.ser(this.RSess_TypeName, {
            id: this.id,
            type: this.type,
            callback: this.callback,
            commitment: this.commitment,
            answer: this.answer
        }).toBytes();
    };
    SuiSession.prototype.de_bcs_bytes = function (bcs_bytes) {
        return this.bcs.de(this.RSess_TypeName, bcs_bytes, 'base64');
    };
    return SuiSession;
}());
exports.SuiSession = SuiSession;
var SuiRecvMessage = /** @class */ (function () {
    function SuiRecvMessage(msgID, fromChain, toChain, 
    // bcs_sqos: Array<SuiSQoSItem>,
    accountName, actionName, 
    // bcs_data: Array<SuiMessageItem>,
    sender, signer, bcs_session) {
        this.msgID = msgID;
        this.fromChain = fromChain;
        this.toChain = toChain;
        this.bcs_sqos = new Array();
        this.accountName = accountName;
        this.actionName = actionName;
        this.bcs_payload = new Array();
        this.sender = sender;
        this.signer = signer;
        this.bcs_session = bcs_session;
    }
    SuiRecvMessage.prototype.add_message_item = function (msgItem) {
        this.bcs_payload.push(msgItem);
    };
    SuiRecvMessage.prototype.add_sqos_item = function (sqosItem) {
        this.bcs_sqos.push(sqosItem);
    };
    SuiRecvMessage.prototype.into_parameters = function () {
        var output = [this.msgID];
        output.push(new Uint8Array(Buffer.from(this.fromChain, 'utf-8')));
        output.push(new Uint8Array(Buffer.from(this.toChain, 'utf-8')));
        // bcs sqos to bcs vector
        var sqos = [];
        for (var idx in this.bcs_sqos) {
            sqos.push(this.bcs_sqos[idx].en_bcs_bytes());
        }
        output.push(sqos);
        // bcs sqos end
        output.push(this.accountName);
        output.push(this.actionName);
        // bcs data to bcs vector
        var payload = [];
        for (var idx in this.bcs_payload) {
            payload.push(this.bcs_payload[idx].en_bcs_bytes());
        }
        output.push(payload);
        // bcs data end
        // output = output.concat([this.sender, this.signer]);
        output.push(this.sender);
        output.push(this.signer);
        // bcs session to bcs vector
        output.push(this.bcs_session.en_bcs_bytes());
        // bcs session end
        return output;
    };
    return SuiRecvMessage;
}());
exports.SuiRecvMessage = SuiRecvMessage;
