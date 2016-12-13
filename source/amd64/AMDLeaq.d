module amd64.AMDLeaq;
import target.TInst, std.outbuffer;
import amd64.AMDReg, amd64.AMDObj;

class AMDLeaq : TInst {

    private AMDReg _reg;
    private AMDObj _where;

    this (AMDReg reg, AMDObj where) {
	this._reg = reg;
	this._where = where;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\tleaq\t%s, %s",
		    this._reg.toString,
		    this._where.toString);
	
	return buf.toString;
    }
    
}
