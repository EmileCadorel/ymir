module amd64.AMDMove;
import target.TInst, amd64.AMDObj;
import std.outbuffer, amd64.AMDReg;

class AMDMove : TInst {

    private AMDObj _left;
    private AMDObj _right;
    private AMDObj _aux;
    
    this (AMDObj left, AMDObj right) {
	this._left = left;
	this._right = right;
	auto l = cast (AMDReg) left;
	auto r = cast (AMDReg) right;
	if (r && l && r.isOff && l.isOff) {
	    this._aux = new AMDReg (REG.getReg ("r14", r.sizeAmd));
	}
    }

    override string toString () {
	auto buf = new OutBuffer;
	if (this._aux is null) {
	    buf.writef("\tmov%s\t%s, %s",
		       this._left.sizeAmd.id,
		       this._left.toString (),
		       this._right.toString ());
	} else {
	    buf.writefln ("\tmov%s\t%s, %s",
		       this._left.sizeAmd.id,
		       this._left.toString (),
		       this._aux.toString);

	    buf.writef("\tmov%s\t%s, %s",
		       this._aux.sizeAmd.id,
		       this._aux.toString (),
		       this._right.toString);
	}
	return buf.toString ();
    }
    

}
