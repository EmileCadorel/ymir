module amd64.AMDMove;
import amd64.AMDConst;
import target.TInst, amd64.AMDObj, amd64.AMDSize;
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
	auto size = this._left.sizeAmd;
	if (cast (AMDConst) this._left) size = this._right.sizeAmd;
	if (this._aux is null) {
	    buf.writef("\tmov%s\t%s, %s",
		       size.id,
		       this._left.toString (),
		       this._right.toString ());
	} else {
	    buf.writefln ("\tmov%s\t%s, %s",
			  size.id,
			  this._left.toString (),
			  this._aux.toString);

	    buf.writef("\tmov%s\t%s, %s",
		       size.id, 
		       this._aux.toString (),
		       this._right.toString);
	}
	return buf.toString ();
    }    


}


class AMDMoveCast : TInst {


    private AMDObj _left;
    private AMDObj _right;
    private AMDObj _aux;
    
    this (AMDObj left, AMDObj right) {
	this._left = left;
	this._right = right;
	auto l = cast (AMDReg) left;
	auto r = cast (AMDReg) right;
	if (r && l && r.isOff && l.isOff) {
	    this._aux = new AMDReg (REG.getReg ("r14", l.sizeAmd));
	}
    }

    override string toString () {
	auto buf = new OutBuffer;
	if (this._aux is null) {
	    buf.writef("\tmovs%s%s\t%s, %s",
		       this._left.sizeAmd.id,
		       this._right.sizeAmd.id,
		       this._left.toString (),
		       this._right.toString ());
	} else {
	    buf.writefln ("\tmov%s\t%s, %s",
		       this._left.sizeAmd.id,
		       this._left.toString (),
		       this._aux.toString);

	    buf.writef("\tmovs%s%s\t%s, %s",
		       this._aux.sizeAmd.id,
		       this._right.sizeAmd.id,
		       this._aux.toString (),
		       this._right.toString);
	}
	return buf.toString ();
    }    
    

}
