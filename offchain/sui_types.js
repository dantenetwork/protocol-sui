"use strict";
exports.__esModule = true;
exports.SuiMessageItem = exports.bcs_value = exports.bcs_value_vec_u128 = exports.SuiMsgType = void 0;
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
    SuiMessageItem.prototype.to_bcs_bytes = function () {
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
