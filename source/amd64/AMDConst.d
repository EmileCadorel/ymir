module amd64.AMDConst;
import amd64.AMDObj, amd64.AMDSize, std.conv;

class AMDConstByte : AMDObj {
    private ubyte _value;

    this (ubyte value) {
	this._value = value;
    }

    override AMDSize sizeAmd () {
	return AMDSize.BYTE;
    }
    
    override string toString () {
	return "$" ~ to!string (this._value);
    }
    
}


class AMDConstQWord : AMDObj {
    private long _value;

    this (long value) {
	this._value = value;
    }

    ref long value () {
	return this._value;
    }
    
    override AMDSize sizeAmd () {
	return AMDSize.QWORD;
    }

    override string toString () {
	return "$" ~ to!string (this._value);
    }
    
}
