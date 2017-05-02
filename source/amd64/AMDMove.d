module amd64.AMDMove;
import amd64.AMDConst;
import target.TInst, amd64.AMDObj, amd64.AMDSize;
import std.outbuffer, amd64.AMDReg;

class AMDMove : TInst {

    private AMDObj _left;
    private AMDObj _right;
    private AMDObj _aux;
    private bool _isAbs;

    
    this (AMDObj left, AMDObj right) {
	this._left = left;
	this._right = right;
	auto l = cast (AMDReg) left;
	auto r = cast (AMDReg) right;
	if (r && l && r.isOff && l.isOff) {
	    this._aux = new AMDReg (REG.getSwap (r.sizeAmd));
	} else if (r && r.isOff && cast (AMDConstDouble) left) {
	    this._aux = new AMDReg (REG.getSwap (r.sizeAmd));
	}

	auto cst = cast (AMDConstDecimal) this._left;
	auto cst2 = cast (AMDConstUDecimal) this._left;
	if (cst && isSigned (this._left.sizeAmd)) {
	    if (cst.value > uint.max || cst.value < int.min) {
		this._isAbs = true;
		if (!this._aux)
		    this._aux = new AMDReg (REG.getSwap (r.sizeAmd));
	    }
	} else if (cst2 && isUnsigned (this._left.sizeAmd)) {
	    if (cst2.value > uint.max) {
		this._isAbs = true;
		if (!this._aux)
		    this._aux = new AMDReg (REG.getSwap (r.sizeAmd));
	    }
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
	    buf.writefln ("\tmov%s%s\t%s, %s",
			  this._isAbs ? "abs" : "",
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

    private string getName () {
	if (this._left.sizeAmd.size >= this._right.sizeAmd.size) {
	    if (auto _r = cast (AMDReg) this._left) 
		_r.resize (this._right.sizeAmd);
	    return "mov" ~ this._right.sizeAmd.id;
	} else {
	    return "movs" ~ this._left.sizeAmd.id ~ this._right.sizeAmd.id;
	}
    }
    
    override string toString () {
	auto buf = new OutBuffer;
	if (this._aux is null) {
	    buf.writef("\t%s\t%s, %s",
		       this.getName (),
		       this._left.toString (),
		       this._right.toString ());
	} else {
	    buf.writefln ("\tmov%s\t%s, %s",
		       this._left.sizeAmd.id,
		       this._left.toString (),
		       this._aux.toString);

	    buf.writef("\t%s\t%s, %s",
		       this.getName (),
		       this._aux.toString (),
		       this._right.toString);
	}
	if (auto _l = cast (AMDReg) this._left) {
	    if (auto _r = cast (AMDReg) this._right)
		if (_r == _l) return ""; // cast inutile
	}
	return buf.toString ();
    }    
    

}
