module amd64.AMDBinop;
import target.TInst, syntax.Tokens, amd64.AMDObj;
import amd64.AMDSize, std.outbuffer;
import target.TInstList, amd64.AMDSet, std.algorithm;
import amd64.AMDReg, amd64.AMDMove, amd64.AMDStd;
import amd64.AMDUnop;

class AMDBinop : TInst {

    private AMDObj _res;
    private AMDObj _left;
    private AMDObj _right;
    private Token _op;
    private TInstList _insts;

    this (AMDObj left, AMDObj right, Token op) {
	this._left = left;
	this._right = right;
	this._op = op;
    }   
    
    this (AMDObj where, AMDObj left, AMDObj right, Token op) {
	this._res = where;
	this._left = left;
	this._right = right;
	this._op = op;
	this.assembly ();
    }

    private bool isNormCom () {
	return find ([Tokens.PLUS, Tokens.STAR], this._op) != [];
    }

    private bool isNorm () {
	return find ([Tokens.MINUS], this._op) != [];
    }

    private bool isTest () {
	if (this._op == Tokens.INF)  opTest (AMDSetType.LOWER);
	else if (this._op == Tokens.SUP) opTest (AMDSetType.GREATER);
	else if (this._op == Tokens.DEQUAL) opTest (AMDSetType.EQUALS);
	else if (this._op == Tokens.SUP_EQUAL) opTest (AMDSetType.GREATER_E);
	else if (this._op == Tokens.INF_EQUAL) opTest (AMDSetType.LOWER_E);
	else if (this._op == Tokens.NOT_EQUAL) opTest (AMDSetType.NOT_EQ);
	else return false;
	return true;
    }
    
    private string opInt () {
	if (this._op == Tokens.MINUS) return "sub";
	else if (this._op == Tokens.PLUS) return "add";
	else if (this._op == Tokens.DEQUAL) return "cmp";
	else if (this._op == Tokens.STAR) return "imul";
	assert (false, "TODO " ~ this._op.descr);
    }

    private void assembly () {
	this._insts = new TInstList;
	if (this.isNormCom ()) this.opNormCom ();
	else if (this.isNorm ()) this.opNorm ();
	else if (this.isTest ()) {}
	else if (this._op == Tokens.DIV) this.opDiv ();
	else if (this._op == Tokens.PERCENT) this.opMod ();
	else assert (false, "TODO " ~ this._op.descr);
    }
    
    private AMDReg initLR (ref AMDReg left, ref AMDReg right, AMDObj l, AMDObj r, AMDObj res) {
	left = cast (AMDReg) l;
	right = cast (AMDReg) r;
	if (!(cast (AMDReg) res) || (cast (AMDReg)res).isOff)
	    return new AMDReg (REG.getSwap (l.sizeAmd));
	else return cast (AMDReg) res;
    }
    
    private void opNormCom () {
	AMDReg lreg, rreg;
	auto ret = initLR (lreg, rreg, this._left, this._right, this._res);
	if (ret == lreg) {
	    this._insts += new AMDBinop (this._right, ret, this._op);
	} else if (ret == rreg) {
	    this._insts += new AMDBinop (this._left, ret, this._op);
	} else {
	    this._insts += new AMDMove (this._left, ret);
	    this._insts += new AMDBinop (this._right, ret, this._op);
	}
	if (this._res != ret) {
	    this._insts += new AMDMove (ret, this._res);
	}
    }

    private void opNorm () {
	AMDReg lreg, rreg;
	auto ret = initLR (lreg, rreg, this._left, this._right, this._res);
	if (ret == rreg) {
	    this._insts += new AMDBinop (this._left, ret, this._op);
	} else if (ret == lreg) {
	    auto aux = new AMDReg (REG.getSwap (this._left.sizeAmd));
	    this._insts += new AMDMove (this._left, aux);
	    this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDBinop (aux, ret, this._op);
	} else {
	    this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDBinop (this._left, ret, this._op);
	}
	if (this._res != ret) {
	    this._insts += new AMDMove (ret, this._res);
	}
    }
    
    private void opTest (AMDSetType type) {
	AMDReg lreg, rreg;
	auto ret = initLR (lreg, rreg, this._left, this._right, this._res);
	auto fin = new AMDReg (REG.getReg (ret.name, AMDSize.BYTE));
	if (ret == lreg) {
	    this._insts += new AMDCmp (this._right, ret);
	    this._insts += new AMDSet (fin, type);
	} else if (ret == rreg) {
	    this._insts += new AMDCmp (this._left, ret);
	    this._insts += new AMDSet (fin, AMDSet.Inv (type));
	} else {
	    this._insts += new AMDMove (this._left, ret);
	    this._insts += new AMDCmp (this._right, ret);
	    this._insts += new AMDSet (fin, type);
	}

	auto aux = fin.clone (this._res.sizeAmd);
	if (this._res != aux)
	    this._insts += new AMDMove (aux, this._res); 
    }

    private void opDiv () {	
	AMDReg lreg, rreg;
	auto ret = initLR (lreg, rreg, this._left, this._right, this._res);
	auto rax = new AMDReg (REG.getReg ("rax", this._left.sizeAmd));
	if (rax == lreg) {
	    this._insts += new AMDCqto;
	    if (ret != rreg)
		this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDUnop (ret, Tokens.DIV);
	} else if (rax == rreg) {
	    this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDMove (this._left, rax);
	    this._insts += new AMDCqto;
	    this._insts += new AMDUnop (ret, Tokens.DIV);
	} else {
	    this._insts += new AMDMove (this._left, rax);
	    this._insts += new AMDCqto;
	    if (ret != rreg)
		this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDUnop (ret, Tokens.DIV);
	}
	this._insts += new AMDMove (rax, this._res);	
    }
    
    private void opMod () {
	AMDReg lreg, rreg;
	auto ret = initLR (lreg, rreg, this._left, this._right, this._res);
	auto rax = new AMDReg (REG.getReg ("rax", this._left.sizeAmd));
	auto rdx = new AMDReg (REG.getReg ("rdx", this._left.sizeAmd));
	if (rax == lreg) {
	    this._insts += new AMDCqto ();
	    if (ret != rreg)
		this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDUnop (ret, Tokens.DIV);
	} else if (rax == rreg) {
	    this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDMove (this._left, rax);
	    this._insts += new AMDCqto;
	    this._insts += new AMDUnop (ret, Tokens.DIV);
	} else {
	    this._insts += new AMDMove (this._left, rax);
	    this._insts += new AMDCqto ();
	    if (ret != rreg)
		this._insts += new AMDMove (this._right, ret);
	    this._insts += new AMDUnop (ret, Tokens.DIV);
	}
	this._insts += new AMDMove (rdx, this._res);
    }
    

    private string opFloat () {
	return "";
    }
    
    override string toString () {
	if (this._insts !is null) {
	    auto buf = new OutBuffer ();
	    foreach (it ; this._insts.inst) {
		buf.writef ("%s", it.toString ());
		if (it !is this._insts.inst [$ - 1]) buf.writef ("\n");
	    }
	    return buf.toString ();
	} else {
	    auto size = this._left.sizeAmd;
	    string op;
	    if (size == AMDSize.BYTE) op = opInt ();	
	    else if (size == AMDSize.WORD) op = opInt ();
	    else if (size == AMDSize.DWORD) op = opInt ();
	    else if (size == AMDSize.QWORD) op = opInt ();
	    else if (size == AMDSize.SPREC) op = opFloat ();
	    else if (size == AMDSize.DPREC) op = opFloat ();
	    else assert (false);
	    
	    auto buf = new OutBuffer ();
	    buf.writef ("\t%s%s\t%s, %s",
			op, size.id,
			this._left.toString (),
			this._right.toString ());
	    return buf.toString ();
	}
    }    
}
