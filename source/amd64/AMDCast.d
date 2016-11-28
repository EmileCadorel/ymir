module amd64.AMDCast;
import target.TInst, amd64.AMDObj;
import amd64.AMDSize, std.outbuffer;

class AMDCast : TInst {

    private AMDObj _left;
    private AMDObj _right;
    
    this (AMDObj left, AMDObj right) {
	this._left = left;
	this._right = right;
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\tmovs%s%s\t%s, %s",
		    this._left.sizeAmd.id,
		    this._right.sizeAmd.id,
		    this._left.toString(),
		    this._right.toString ());
	return buf.toString ();
    }

}
