module lint.LConst;
import lint.LExp, std.container;
import std.conv, lint.LSize;

abstract class LConst : LExp {
    final override bool isInst () {
	return false;
    }
}

class LConstByte : LConst {
    private ubyte _value;

    this (ubyte value) {
	this._value = value;
    }

    override LSize size () {
	return LSize.BYTE;
    }
    
    ubyte value () { return this._value; }
    
    override string toString () {
	return "$(" ~ to!string (this._value) ~ ")";
    }
}

class LConstWord : LConst {
    private short _value;

    this (short value) {
	this._value = value;
    }
    
    override LSize size () {
	return LSize.SHORT;
    }
    
    short value () { return this._value; }
}

class LConstDWord : LConst {
    
    private ulong _value;
    private LSize _mult = LSize.NONE;
    
    this (int value) {
	this._value = value;
    }

    this (ulong value, LSize mult) {
	this._value = value;
	this._mult = mult;
    }
    
    this (ulong value) {
	this._value = value;
    }
    
    override LSize size () {
	return LSize.INT;
    }
    
    LSize mult () {
	return this._mult;
    }

    ulong value () { return this._value; }
    
    override string toString () {
	return "DW[" ~ to!string (this._value) ~ " * " ~ to!string (this._mult) ~ "]";
    }
    
}

class LConstQWord : LConst {
    private long _value;
    private LSize _mult = LSize.NONE;
    
    this (long value) {
	this._value = value;
    }

    this (long value, LSize mult) {
	this._value = value;
	this._mult = mult;
    }

    LSize mult () {
	return this._mult;
    }
   
    override LSize size () {
	return LSize.LONG;
    }
    
    long value () { return this._value; }

    override string toString () {
	return "$(" ~ to!string (this._value) ~ ")";
    }
    
}

class LConstFloat : LConst {
    private float _value;
    
    this (float value) {
	this._value = value;
    }

    override LSize size () {
	return LSize.FLOAT;
    }
    
    float value () { return this._value; }
    
    override string toString () {
	return "SP[" ~ to!string (this._value) ~ "]";
    }
    
}

class LConstDouble : LConst {
    private double _value;

    this (double value) {
	this._value = value;
    }

    override LSize size () {
	return LSize.DOUBLE;
    }
    
    double value () {
	return this._value;
    }
    
}

class LConstString : LConst {
    private string _value;

    this (string value) {
	this._value = value;
    }

    override LSize size () {
	return LSize.LONG;
    }
    
    string value () {
	return this._value;
    }
    
}

class LConstFunc : LConst {
    private string _value;

    this (string value) {
	this._value = value;
    }

    string name () {
	return this._value;
    }

    override string toString () {
	return "$" ~ this._value;
    }
    
}

class LConstArray : LConst {
        
    private Array!LExp _exp;

    this (Array!LExp exp) {
	this._exp = exp;
    }

    ulong length () const {
	return this._exp.length;
    }
        
    LExp opIndex (ulong i) {
	return this._exp[i];
    }    
   
}

class LParam : LConst {

    private Array!LExp _exps;
    private LSize _size;
    
    this (Array!LExp exp, LSize size) {
	this._exps = exp;
	this._size = size;
    }

    override LSize size () {
	return this._size;
    }
    
    Array!LExp params () {
	return this._exps;
    }    
    
    LExp opIndex (ulong i) {
	return this._exps [i];
    }
    
}

