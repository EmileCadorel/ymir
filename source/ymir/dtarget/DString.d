module ymir.dtarget.DString;
import ymir.dtarget._;

import std.format, std.outbuffer;

class DString : DExpression {

    private string _value;

    this (string value) {
	this._value = value;
    }

    override string toString () {
	auto buf = new OutBuffer;
	foreach (it ; this._value) {
	    if (it == '\"') buf.write ("\\\"");
	    else if (it == '\'') buf.write ("\\\'");
	    else if (it == '\n') buf.write ("\\n");
	    else buf.write (it);
	}
	buf.write ("\"");
	return format ("\"%s", buf.toString);
    }

    
}
