module amd64.AMDCall;
import target.TInst, std.outbuffer;
import amd64.AMDObj;

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

class AMDCallDyn : TInst {

    private AMDObj _where;

    this (AMDObj where) {
	this._where = where;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\tcall\t*%s", this._where.toString ());
	return buf.toString ();
    }
    

}
