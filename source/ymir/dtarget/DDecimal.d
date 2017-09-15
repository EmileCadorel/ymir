module ymir.dtarget.DDecimal;
import ymir.dtarget._;
import ymir.lint._;

import std.conv, std.bigint;

class DDecimal : DExpression {

    private BigInt _value;

    this (T) (T  value) {
	this._value = value;
    }

    this (LSize size) {
	final switch (size.id) {
	case LSize.BYTE.id : this._value = 1; break;
	case LSize.UBYTE.id : this._value = 1; break;
	case LSize.SHORT.id : this._value = 2; break;
	case LSize.USHORT.id : this._value = 2; break;
	case LSize.INT.id : this._value = 4; break;
	case LSize.UINT.id : this._value = 4; break;
	case LSize.LONG.id : this._value = 8; break;
	case LSize.ULONG.id : this._value = 8; break;
	case LSize.FLOAT.id : this._value = 4; break;
	case LSize.DOUBLE.id : this._value = 8; break;
	case LSize.NONE.id : this._value = 0; break;
	}
    }
    
    override string toString () {
	return this._value.to!string;
    }    
    
}
