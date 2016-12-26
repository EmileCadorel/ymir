module amd64.AMDCvtt;
import amd64.AMDConst;
import target.TInst, amd64.AMDObj, amd64.AMDSize;
import std.outbuffer, amd64.AMDReg;

class AMDCvtt : TInst {

    private AMDObj _left;
    private AMDObj _right;

    this (AMDObj left, AMDObj right) {
	this._left = left;
	this._right = right;
    }

    private string getName () {
	if (this._left.sizeAmd.id == AMDSize.DPREC.id) {
	    if (this._right.sizeAmd.id == AMDSize.SPREC.id) return "cvtsd2ss";
	    else if (this._right.sizeAmd.id == AMDSize.DWORD.id) return "cvttsd2si";
	    else if (this._right.sizeAmd.id == AMDSize.QWORD.id) return "cvttsd2siq";
	    assert (false);
	} else if (this._left.sizeAmd.id == AMDSize.SPREC.id) {
	    if (this._right.sizeAmd.id == AMDSize.DPREC.id) return "cvtss2sd";
	    else if (this._right.sizeAmd.id == AMDSize.DWORD.id) return "cvttss2si";
	    else if (this._right.sizeAmd.id == AMDSize.QWORD.id) return "cvttss2siq";
	    assert (false);
	} else if (this._left.sizeAmd.id == AMDSize.DWORD.id) {
	    if (this._right.sizeAmd.id == AMDSize.DPREC.id) return "cvtsi2sd";
	    else if (this._right.sizeAmd.id == AMDSize.SPREC.id) return "cvtsi2ss";
	    assert (false);
	} else if (this._left.sizeAmd.id == AMDSize.QWORD.id) {
	    if (this._right.sizeAmd.id == AMDSize.DPREC.id) return "cvtsi2sdq";
	    else if (this._right.sizeAmd.id == AMDSize.SPREC.id) return "cvtsi2ssq";
	    assert (false);
	} assert (false);
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\t%s\t%s, %s", this.getName (),
		    this._left.toString (),
		    this._right.toString ());
	return buf.toString ();
    }

}
