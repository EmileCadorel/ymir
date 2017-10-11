module ymir.dtarget.DConstArray;
import ymir.dtarget._;

import std.outbuffer, std.container;

class DConstArray : DExpression {

    private Array!DExpression _values;

    void addValue (DExpression value) {
	this._values.insertBack (value);
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("[");
	foreach (it ; this._values) {
	    buf.writef ("%s%s", it, it is this._values [$ - 1] ? "" : ", ");
	}
	buf.writef ("]");
	return buf.toString;
    }

} 
