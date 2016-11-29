module amd64.AMDCall;
import target.TInst, std.outbuffer;

class AMDCall : TInst {

    private string _name;

    this (string name) {
	this._name = name;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\tcall\t%s", this._name);
	return buf.toString ();
    }
       
}
