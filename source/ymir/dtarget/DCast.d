module ymir.dtarget.DCast;
import ymir.dtarget._;

import std.format;

// Type standart en D
enum Dlang {
    CHAR = "char",
    BOOL = "bool",
    STRING = "string",
    BYTE = "byte",
    UBYTE = "ubyte",
    SHORT = "short",
    USHORT = "ushort",    
    INT = "int",
    UINT = "uint",    
    LONG = "long",
    ULONG = "ulong",
    FLOAT = "float",
    DOUBLE = "double"    
}


class DCast : DExpression {

    private DType _type;

    private DExpression _who;

    this (DType type, DExpression who) {
	this._type = type;
	this._who = who;
    }

    override string toString () {
	return format ("cast (%s) (%s)", this._type.toString, this._who.toString);
    }
    
}
