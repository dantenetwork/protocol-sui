import {BCS, fromB64, toB64, getSuiMoveConfig } from '@mysten/bcs'

export enum SuiMsgType {
    suiString = 0,
    suiU8 = 1,
    // suiU16 = 2,
    // suiU32 = 3,
    suiU64 = 4,
    suiU128 = 5,
    // suiI8 = 6,
    // suiI16 = 7,
    // suiI32 = 8,
    // suiI64 = 9,
    // suiI128 = 10,
    suiVecString = 11,
    // suiVecU8 = 12,
    // suiVecU16 = 13,
    // suiVecU32 = 14,
    suiVecU64 = 15,
    suiVecU128 = 16,
    // suiVecI8 = 17,
    // suiVecI16 = 18,
    // suiVecI32 = 19,
    // suiVecI64 = 20,
    // suiVecI128 = 21,
    suiAddress = 22,
};

const bcs4value = new BCS(getSuiMoveConfig());

function string_bcs_value(value: string) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(BCS.STRING, value);
}

function u8_bcs_value(value: number) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(BCS.U8, value);
}

function u64_bcs_value(value: string) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(BCS.U64, value);
}

function u128_bcs_value(value: string) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(BCS.U128, value); 
}

function vec_string_bcs_value(value: Array<string>) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser('vector<string>', value); 
}

function vec_u64_bcs_value(value: BigUint64Array) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser('vector<u64>', value);
}

function vec_u128_bcs_value(value: Array<string>) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser('vector<u128>', value);
}

export function bcs_value_vec_u128(bcsBytes: Uint8Array) {
    return bcs4value.de('vector<u128>', bcsBytes, 'base64');
}

function address_bcs_value(value: string) {
    // const bcs4value = new BCS(getSuiMoveConfig());
    return bcs4value.ser(BCS.ADDRESS, value);
}

export function bcs_value(type: SuiMsgType, value: string | Array<string> | number | Uint8Array | BigUint64Array | Array<number>) {
    switch (type) {
        case SuiMsgType.suiString: {
            return string_bcs_value(value as string);
            break;
        }
        case SuiMsgType.suiU8: {
            return u8_bcs_value(value as number);
            break;
        }
        case SuiMsgType.suiU64: {
            return u64_bcs_value(value as string);
            break;
        }
        case SuiMsgType.suiU128: {
            return u128_bcs_value(value as string);
            break;
        }
        case SuiMsgType.suiVecString: {
            return vec_string_bcs_value(value as Array<string>);
            break;
        }
        case SuiMsgType.suiVecU64: {
            return vec_u64_bcs_value(value as BigUint64Array);
            break;
        }
        case SuiMsgType.suiVecU128: {
            return vec_u128_bcs_value(value as Array<string>);
            break;
        }
        case SuiMsgType.suiAddress: {
            return address_bcs_value(value as string);
            break;
        }
        default:
            console.log(`Sorry, we are out of ${type}.`);
    }
}

export class SuiMessageItem {
    name: string;
    type: SuiMsgType;
    value: Uint8Array | undefined;
    bcs: BCS;
    RMI_TypeName: string;

    constructor(name: string, type: SuiMsgType, value: string | Array<string> | number | Uint8Array | BigUint64Array | Array<number>) {
        this.name = name;
        this.type = type;
        this.value = bcs_value(type, value)?.toBytes();
        
        this.bcs = new BCS(getSuiMoveConfig());

        this.RMI_TypeName = 'RawMessageItem';
        this.bcs.registerStructType(this.RMI_TypeName, {
            name: BCS.STRING,
            type: BCS.U8,
            value: BCS.STRING
        });
    }

    en_bcs_bytes() {
        if (this.value != undefined) {
            return this.bcs.ser(this.RMI_TypeName, {
                name: this.name,
                type: this.type,
                value: Buffer.from(this.value).toString('base64'),
            }).toBytes();
        }
    }

    de_bcs_bytes(bcs_bytes: Uint8Array) {
        return this.bcs.de(this.RMI_TypeName, bcs_bytes, 'base64');
    }
}

export enum SQoSType {
    Reveal = 0,
    Challenge,
    Threshold,
    Priority,
    ExceptionRollback,
    SelectionDelay,
    Anonymous,
    Identity,
    Isolation,
    CrossVerify
}

export class SQoSItem {
    t: SQoSType;
    v: Uint8Array;
    bcs: BCS;
    RSI_TypeName: string;
    
    constructor(t: SQoSType, v: Uint8Array) {
        this.t = t;
        this.v = v;

        this.RSI_TypeName = 'RawSQoSItem';
        this.bcs = new BCS(getSuiMoveConfig());
        this.bcs.registerStructType(this.RSI_TypeName, {
            type: BCS.U8,
            value: BCS.STRING
        });
    }

    en_bcs_bytes() {
        return this.bcs.ser(this.RSI_TypeName, {
            type: this.t,
            value: Buffer.from(this.v).toString('base64'),
        }).toBytes();
    }

    de_bcs_bytes(bcs_bytes: Uint8Array) {
        return this.bcs.de(this.RSI_TypeName, bcs_bytes, 'base64');
    }
}

export enum SessionType {
    MessageSend = 1,
    CallOut = 2,
    Callback = 3,
    LocolErr = 104,
    RemoteErr = 105
}

export class SuiSession {
    id: string;
    type: SessionType;
    callback: Array<Uint8Array>;
    commitment: Array<Uint8Array>;
    answer: Array<Uint8Array>;
    // answer: {"none": null} | { some: string; };

    bcs: BCS;
    RSess_TypeName: string;

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

    constructor(id: string, type: SessionType, 
                    callback: Uint8Array|null = null, 
                    commitment: Uint8Array|null = null,
                    answer: Uint8Array|null = null) {
        this.id = id;
        this.type = type;
        this.callback = (callback == null) ? [] : [callback];
        this.commitment = (commitment == null) ? [] : [commitment];
        this.answer = (answer == null) ? [] : [answer];

        this.RSess_TypeName = 'RawSession';
        this.bcs = new BCS(getSuiMoveConfig());
        this.bcs.registerStructType('RawSession', {
            id: BCS.U128,
            type: BCS.U8,
            callback: 'vector<vector<u8>>',
            commitment: 'vector<vector<u8>>',
            answer: 'vector<vector<u8>>'
        });
    }

    en_bcs_bytes() {
        return this.bcs.ser(this.RSess_TypeName, {
            id: this.id,
            type: this.type,
            callback: this.callback,
            commitment: this.commitment,
            answer: this.answer
        }).toBytes();
    }

    de_bcs_bytes(bcs_bytes: Uint8Array) {
        return this.bcs.de(this.RSess_TypeName, bcs_bytes, 'base64');
    }
}
