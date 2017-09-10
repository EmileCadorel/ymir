module ymir.amd64.AMDLabel;
import ymir.target.TLabel, ymir.target.TInstList;
import std.outbuffer, std.stdio;
import ymir.amd64.AMDLocus;

class AMDLabel : TLabel {

    private string _id;
    private TInstList _inst;

    this (string id) {
	this._id = id;
    }
    
    this (string id, TInstList list) {
	this._id = id;
	this._inst = list;
    }

    ref TInstList inst () {
	return this._inst;
    }

    ref string id () {
	return this._id;
    }
    
    override string toString () {
	auto buf = new OutBuffer;
	buf.writef ("%s:\n", this._id);
	AMDLocus last = null;
	if (this._inst !is null) {
	    foreach (it ; this._inst.inst) {
		if (auto _l = cast (AMDLocus) it) {
		    if (!last || last.loc.line != _l.loc.line || last.loc.file != _l.loc.file) 
			buf.writef ("%s\n", it.toString ());
		    last = _l;
		} else {
		    buf.writef ("%s\n", it.toString ());
		    last = null;
		}
	    }
	} else {
	    buf.writef ("\tnone\n");
	}
	return buf.toString ();
    }

}
