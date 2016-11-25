module amd64.AMDMove;
import target.TInst, amd64.AMDObj;
import std.outbuffer;

class AMDMove : TInst {

    private AMDObj _left;
    private AMDObj _right;
    
    this (AMDObj left, AMDObj right) {
	this._left = left;
	this._right = right;
    }

    override string toString () {
	auto buf = new OutBuffer;
	buf.writef("\tmov%s\t%s, %s",
		   this._left.sizeAmd.id,
		   this._left.toString (),
		   this._right.toString ());
	return buf.toString ();
    }
    

}
