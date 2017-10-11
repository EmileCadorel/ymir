module ymir.dtarget.DParamList;
import ymir.dtarget._;

import std.outbuffer, std.container;

class DParamList : DExpression {

    private Array!DExpression _params;

    void addParam (DExpression param) {
	this._params.insertBack (param);
    }

    Array!DExpression params () {
	return this._params;
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; this._params) {
	    buf.writef ("%s%s", it.toString, it is this._params [$ - 1] ? "" : ", ");
	}
	return buf.toString ();
    }
    

}
