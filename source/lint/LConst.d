module lint.LConst;
import lint.LExp, std.container;
import std.conv;

abstract class LConst : LExp {}


class LConstByte : LConst {
    private short _value;

    this (short value) {
	this._value = value;
    }

}

class LConstDWord : LConst {
    private int _value;

    this (int value) {
	this._value = value;
    }

    override string toString () {
	return "DW[" ~ to!string (this._value) ~ "]";
    }
    
}

class LConstQWord : LConst {
    private long _value;

    this (long value) {
	this._value = value;
    }
}

class LConstFloat : LConst {
    private float _value;
    
    this (float value) {
	this._value = value;
    }

    override string toString () {
	return "SP[" ~ to!string (this._value) ~ "]";
    }
    
}

class LConstDouble : LConst {
    private double _value;

    this (double value) {
	this._value = value;
    }
}

class LConstString : LConst {
    private string _value;

    this (string value) {
	this._value = value;
    }

}

class LConstFunc : LConst {
    private string _value;

    this (string value) {
	this._value = value;
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

