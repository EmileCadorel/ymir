module lint.LConst;
import lint.LExp, std.container;
import std.conv, lint.LSize;

abstract class LConst : LExp {
    final override bool isInst () {
	return false;
    }
}


class LConstDecimal : LConst {
    private long _value;
    private LSize _size;
    private LSize _mult = LSize.NONE;
    
    this (long value, LSize size) {
	this._value = value;
	this._size = size;
    }

    this (long value, LSize size, LSize mult) {
	this._value = value;
	this._size = size;
	this._mult = mult;
    }
    
    override LSize size () {
	return this._size;
    }

    long value () {
	return this._value;
    }

    LSize mult () {
	return this._mult;
    }
    
    override string toString () {
	if (this._mult != LSize.NONE && this._value != 0) {
	    return "$(" ~ to!string (this._value) ~ ',' ~ to!string (this._mult) ~ ")";
	} else
	    return "$(" ~ to!string (this._value) ~ ")";
    }    
    
}

class LConstUDecimal : LConst {
    private ulong _value;
    private LSize _size;
    private LSize _mult = LSize.NONE;
    
    this (ulong value, LSize size) {
	this._value = value;
	this._size = size;
    }

    this (ulong value, LSize size, LSize mult) {
	this._value = value;
	this._size = size;
	this._mult = mult;
    }
    
    override LSize size () {
	return this._size;
    }

    LSize mult () {
	return this._mult;
    }
    
    ulong value () {
	return this._value;
    }

    override string toString () {
	if (this._mult != LSize.NONE && this._value != 0) {
	    return "$(" ~ to!string (this._value) ~ ',' ~ to!string (this._mult) ~ ")";
	} else
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

    override LSize size() {
	return LSize.LONG;
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

