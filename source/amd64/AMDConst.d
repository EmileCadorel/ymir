module amd64.AMDConst;
import amd64.AMDObj, amd64.AMDSize, std.conv;
import target.TInst, amd64.AMDRodata, std.outbuffer;

class AMDConstByte : AMDObj {
    private ubyte _value;

    this (ubyte value) {
	this._value = value;
    }

    ubyte value () {
	return this._value;
    }
    
    override AMDSize sizeAmd () {
	return AMDSize.BYTE;
    }
    
    override string toString () {
	return "$" ~ to!string (this._value);
    }
    
}

class AMDConstDWord : AMDObj {
    private long _value;

    this (long value) {
	this._value = value;
    }

    ref long value () {
	return this._value;
    }
    
    override AMDSize sizeAmd () {
	return AMDSize.DWORD;
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


class AMDOLabel : TInst {

    private string _name;
    private ulong _id;
    private static ulong __lastId__ = 0;

    
    this () {
	this._id = __lastId__;
	__lastId__ ++;
    }

    ref ulong id () {
	return this._id;
    }
    
    override string toString () {
	return ".LC" ~ to!string (this._id) ~ ":\n";
    }    
}

class AMDString : TInst {

    private string _value;

    this (string value) {
	this._value = value;
    }

    override string toString () {
	auto buf = new OutBuffer;
	buf.writef ("\t.string \"");
	foreach (it ; this._value) {
	    if (it == '\n') buf.write ("\\n");
	    else buf.write (it);
	}
	buf.write ("\"\n");
	return buf.toString ();
    }
}

class AMDConstString : AMDObj {
    
    private string _value;
    private AMDOLabel _label;
    private AMDOLabel [string] __labels__;

    
    this (string value) {
	this._value = value;
	auto lbl = (value in __labels__);
	if (lbl is null) {
	    this._label = new AMDOLabel ();
	    __labels__ [value] = this._label;
	    AMDRodata.insts += this._label;
	    AMDRodata.insts += new AMDString (this._value);
	} else this._label = *lbl;
    }

    override AMDSize sizeAmd () {
	return AMDSize.QWORD;
    }
        
    override string toString () {
	return "$.LC" ~ to!string (this._label.id);
    }
    
}
