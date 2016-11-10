module target.TInstList;
import target.TInst, target.TExp;
import std.container, std.outbuffer;

class TInstList {

    private Array!TInst _inst;

    this () {}

    this (Array!TInst inst) {
	this._inst = inst;
    }

    this (TInst inst) {
	this._inst.insertBack (inst);
    }
    
    Array!TInst inst () {
	return this._inst;
    }

    TInstList opBinary (string op : "+") (TInstList other) {
	Array!TInst ret;
	foreach (it ; this._inst) ret.insertBack (it);
	foreach (it ; other._inst) ret.insertBack (it);
	return new TInstList (ret);
    }

    TInstList opOpAssign (string op : "+") (TInst other) {
	this._inst.insertBack (other);
	return this;
    }
    
    TInstList opOpAssign (string op : "+") (TInstList other) {
	foreach (it ; other._inst) this._inst.insertBack (it);
	return this;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	if (!this._inst.empty) buf.write ("\n");
	foreach (it ; this._inst) {
	    buf.writef ("%s", it.toString ());	    
	}
	return buf.toString ();
    }    
    
}
