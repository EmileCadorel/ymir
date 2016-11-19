module ybyte.YBSysCall;
import target.TExp, target.TInst, std.container;
import std.conv, std.outbuffer;

class YBSysCall : TInst {

    private Array!TExp _exps;
    private string _name;

    this (string name, Array!TExp exps) {
	this._name = name;
	this._exps = exps;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\tsystem\t%s [",
		      this._name);
	foreach (it ; this._exps) {
	    buf.write (it.toString ());
	    if (it != this._exps[$ - 1])
		buf.write (", ");
	}
	buf.writefln ("]");
	return buf.toString ();
    }

}
