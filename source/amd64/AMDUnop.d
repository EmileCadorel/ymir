module amd64.AMDUnop;
import target.TInst;
import amd64.AMDObj, syntax.Tokens;
import std.outbuffer, amd64.AMDSize;

class AMDUnop : TInst {

    private AMDObj _obj;
    private Token _op;

    this (AMDObj obj, Token op) {
	this._obj = obj;
	this._op = op;
    }
    
    private string opInt () {
	if (this._op == Tokens.DIV) return "idiv";
	else if (this._op == Tokens.MINUS) return "neg";
	else assert (false);
    }

    override string toString () {
	auto buf = new OutBuffer ();
	string op;
	if (this._obj.sizeAmd == AMDSize.BYTE) op = this.opInt ();
	else if (this._obj.sizeAmd == AMDSize.WORD) op = this.opInt ();
	else if (this._obj.sizeAmd == AMDSize.DWORD) op = this.opInt ();
	else if (this._obj.sizeAmd == AMDSize.QWORD) op = this.opInt ();
	else if (this._obj.sizeAmd == AMDSize.SPREC) op = this.opInt ();
	else if (this._obj.sizeAmd == AMDSize.DPREC) op = this.opInt ();
	buf.writef ("\t%s%s\t%s", op, this._obj.sizeAmd.id, this._obj.toString ());
	return buf.toString ();
    }
    
    
}

