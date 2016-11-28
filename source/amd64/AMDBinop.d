module amd64.AMDBinop;
import target.TInst, syntax.Tokens, amd64.AMDObj;
import amd64.AMDSize, std.outbuffer;

class AMDUnop : TInst {
    private AMDObj _elem;
    private Token _op;
    
    this (AMDObj elem, Tokens op) {
	this._elem = elem;
	this._op = op;
    }

    private string opInt () {
	if (this._op == Tokens.INF) return "setl";
	else if (this._op == Tokens.INF_EQUAL) return "setle";
	else if (this._op == Tokens.NOT_EQUAL) return "setne";
	else if (this._op == Tokens.SUP) return "setg";
	else if (this._op == Tokens.SUP_EQUAL) return "setge";
	assert (false, "TODO " ~ this._op.descr);
    }

    override string toString () {
	auto buf = new OutBuffer ();
	buf.writef ("\t%s\t%s", opInt (), this._elem.toString ());
	return buf.toString ();
    }
    
}


class AMDBinop : TInst {

    private AMDObj _left;
    private AMDObj _right;
    private Token _op;
    
    this (AMDObj left, AMDObj right, Token op) {
	this._left = left;
	this._right = right;
	this._op = op;
    }

    private string opInt () {
	if (this._op == Tokens.MINUS) return "sub";
	else if (this._op == Tokens.PLUS) return "add";
	else if (this._op == Tokens.DEQUAL) return "cmp";
	else if (this._op == Tokens.STAR) return "imul";
	assert (false, "TODO " ~ this._op.descr);
    }

    private string opFloat () {
	return "";
    }
    
    override string toString () {
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
