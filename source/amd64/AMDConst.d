module amd64.AMDConst;
import amd64.AMDObj, amd64.AMDSize, std.conv;
import target.TInst, amd64.AMDRodata, std.outbuffer;
import std.format, std.string, std.array;
import amd64.AMDStd;

class AMDConst : AMDObj {
}

class AMDConstDecimal : AMDConst {
    private long _value;
    private AMDSize _size;
    
    this (long value, AMDSize size) {
	this._value = value;
	this._size = size;
    }

    ref long value () {
	return this._value;
    }

    override AMDSize sizeAmd () {
	return this._size;
    }

    override string toString () {
	return "$" ~ to!string (this._value);
    }
}

class AMDConstUDecimal : AMDConst {
    private long _value;
    private AMDSize _size;
    
    this (long value, AMDSize size) {
	this._value = value;
	this._size = size;
    }

    ref long value () {
	return this._value;
    }

    override AMDSize sizeAmd () {
	return this._size;
    }

    override string toString () {
	return "$" ~ to!string (this._value);
    }
}


class AMDConstDouble : AMDConst {
    private double _value;
    private AMDOLabel _label;
    private AMDOLabel [string] __alls__;
    
    this (double value) {
	this._value = value;
	this.compute ();
    }

    private void compute () {
	union i {double x; long i;}
	i h;
	h.x = this._value;
	auto writer = appender!string ();
	writer.formattedWrite ("%X", h.i);
	string val = writer.data;
	auto elem = val in __alls__;
	if (!elem) {
	    if (val == "0") val = rightJustify ("", 16, '0');
	    auto begin = val [0 .. 8];
	    auto end = val [8 .. val.length];
	    long val1, val2;
	    formattedRead (begin, "%x", &val1);
	    formattedRead (end, "%x", &val2);
	    this._label = new AMDOLabel ("LCD");
	    this._label.isRef = true;
	    AMDRodata.insts += new AMDAlign (8);
	    AMDRodata.insts += this._label;
	    AMDRodata.insts += new AMDLong (to!string (val2));
	    AMDRodata.insts += new AMDLong (to!string (val1));
	    __alls__ [val] = this._label;
	} else {
	    this._label = *elem;
	}
    }

    ref double value () {
	return this._value;
    }
    
    override AMDSize sizeAmd () {
	return AMDSize.DPREC;
    }

    override string toString () {
	return ".LCD" ~ to!string (this._label.id) ~ "(%rip)";
    }
}

class AMDOLabel : TInst {

    private string _name;
    private ulong _id;
    private static ulong __lastId__ = 0;
    private bool _isRef; // est recupere avec %rip
    
    this (string name = "LC") {
	this._name = "." ~ name;
	this._id = __lastId__;
	__lastId__ ++;
    }

    ref ulong id () {
	return this._id;
    }

    ref bool isRef () {
	return this._isRef;
    }
    
    override string toString () {
	return this._name ~ to!string (this._id) ~ ":\n";
    }    
}

class AMDLong : TInst {
    private string _nb;

    this (string nb) {
	this._nb = nb;	
    }

    override string toString () {
	return "\t.long\t" ~ (this._nb) ~ "\n";
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
    private static AMDOLabel [string] __labels__;

    
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

class AMDConstFunc : AMDObj {

    private string _name;

    this (string name) {
	this._name = name;
    }

    override string toString () {
	return "$" ~ this._name;
    }

    override AMDSize sizeAmd () {
	return AMDSize.QWORD;
    }
    
}
