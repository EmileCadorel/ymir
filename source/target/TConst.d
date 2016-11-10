module target.TConst;
import target.TExp, std.container, std.conv;

class TConst : TExp {
}

class TConstByte : TConst {
    private short _value;

    this (short value) {
	this._value = value;
    }

    override int size () {
	return 1;
    }

    override string toString () {
	return "B[" ~ to!string (this._value) ~ "]";
    }
    
}

class TConstDWord : TConst {
    private int _value;

    this (int value) {
	this._value = value;
    }

    int value () { return this._value; }

    override int size () {
	return 4;
    }
    
    override string toString () {
	return "DW[" ~ to!string (this._value) ~ "]";
    }
    
}

class TConstQWord : TConst {
    private long _value;

    this (long value) {
	this._value = value;
    }

    override int size () {
	return 8;
    }
    
    long value () { return this._value; }
}

class TConstFloat : TConst {
    private float _value;
    
    this (float value) {
	this._value = value;
    }

    float value () {
	return this._value;
    }	

    override int size () {
	return -4;
    }
    
    override string toString () {
	return "SP[" ~ to!string (this._value) ~ "]";
    }
    
}

class TConstDouble : TConst {
    private double _value;

    this (double value) {
	this._value = value;
    }

    override int size () {
	return -8;
    }
    
    double value () {
	return this._value;
    }
}

class TConstString : TConst {
    private string _value;

    this (string value) {
	this._value = value;
    }
    
}

class TConstFunc : TConst {
    private string _value;

    this (string value) {
	this._value = value;
    }

    override int size () {
	return -8;
    }
    
}

class TConstArray : TConst {
        
    private Array!TExp _exp;

    this (Array!TExp exp) {
	this._exp = exp;
    }
       
    ulong length () const {
	return this._exp.length;
    }
        
    TExp opIndex (ulong i) {
	return this._exp[i];
    }    

}

