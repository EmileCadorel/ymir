module lint.LConst;
import lint.LExp, std.container;
import std.conv;

abstract class LConst : LExp {
    final override bool isInst () {
	return false;
    }
}

class LConstByte : LConst {
    private byte _value;

    this (byte value) {
	this._value = value;
    }

    override int size () {
	return 1;
    }
    
    byte value () { return this._value; }
    
}

class LConstWord : LConst {
    private short _value;

    this (short value) {
	this._value = value;
    }

    short value () { return this._value; }
}

class LConstDWord : LConst {
    private int _value;

    this (int value) {
	this._value = value;
    }

    override int size () {
	return 4;
    }
    
    int value () { return this._value; }
    
    override string toString () {
	return "DW[" ~ to!string (this._value) ~ "]";
    }
    
}

class LConstQWord : LConst {
    private long _value;
    
    this (long value) {
	this._value = value;
    }

    override int size () {
	return 8;
    }
    
    long value () { return this._value; }
    
}

class LConstFloat : LConst {
    private float _value;
    
    this (float value) {
	this._value = value;
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

    double value () {
	return this._value;
    }
    
}

class LConstString : LConst {
    private string _value;

    this (string value) {
	this._value = value;
    }

    override int size () {
	return 8;
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

