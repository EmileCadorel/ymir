module amd64.AMDLabel;
import target.TLabel, target.TInstList;
import std.outbuffer;

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
	if (this._inst !is null) {
	    foreach (it ; this._inst.inst) {
		buf.writef ("%s\n", it.toString ());
	    }
	} else {
	    buf.writef ("\tnone\n");
	}
	return buf.toString ();
    }

}
