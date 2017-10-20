module ymir.dtarget.DDecimal;
import ymir.dtarget._;
import ymir.lint._;
import ymir.ast._;

import std.conv, std.bigint;

class DDecimal : DExpression {

    private BigInt _value;

    private bool _isSigned = true;
    
    this (T) (T value) {
	this._value = value;
    }

    this (T) (bool signed, T value) {
	this._isSigned = signed;
	this._value = value;
    }

    
    this (T) (DecimalConst cst, T  value) {
	final switch (cst.id) {
	case DecimalConst.BYTE.id : this._value = value.to!byte; break;
	case DecimalConst.UBYTE.id : this._value = value.to!ubyte; this._isSigned = false; break;
	case DecimalConst.SHORT.id : this._value = value.to!short; break;
	case DecimalConst.USHORT.id : this._value = value.to!ushort; this._isSigned = false; break;
	case DecimalConst.INT.id : this._value = value.to!int; break;
	case DecimalConst.UINT.id : this._value = value.to!uint; this._isSigned = false; break;
	case DecimalConst.LONG.id: this._value = value.to!long; break;
	case DecimalConst.ULONG.id : this._value = value.to!ulong; this._isSigned = false; break;
	}
    }
    
    this (LSize size) {
	this._isSigned = false; 
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
	if (this._isSigned)
	    return this._value.to!string;
	else return this._value.to!string ~ "U";
    }    
    
}
