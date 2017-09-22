module  ymir.dtarget.DProto;
import ymir.lint._;
import ymir.dtarget._;
import ymir.semantic._;

import std.outbuffer;

class DProto : DFrame {

    private bool _isVariadic;
    
    this (string name) {
	super (name);
    }

    ref isVariadic () {
	return this._isVariadic;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("extern (C) %s %s (", super.type.simpleString, super.name);
	foreach (it ; this._params) {
	    buf.writef ("%s%s", it,
			(it is this._params [$ - 1] && !this._isVariadic) ? "" : ", ");
	}
	if (this._isVariadic) 
	    buf.writef ("...);");
	else buf.writef (");");
	return buf.toString ();
    }
    
}
