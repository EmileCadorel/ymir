module ymir.amd64.AMDUnop;
import ymir.target.TInst;
import ymir.amd64.AMDObj, ymir.syntax.Tokens;
import std.outbuffer, ymir.amd64.AMDSize;

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
	else if (this._op == Tokens.NOT) return "xor";
	else if (this._op == Tokens.DPLUS) return "inc";
	else if (this._op == Tokens.DMINUS) return "dec";
	else assert (false);
    }

    private string opFloat () {
	if (this._op == Tokens.SQRT) return "sqrt";
	else if (this._op == Tokens.MINUS) return "neg";
	else assert (false);
    }
    
    override string toString () {
	auto buf = new OutBuffer ();
	string op;
	
	if (this._obj.sizeAmd == AMDSize.BYTE) op = this.opInt ();
	else if (isInt (this._obj.sizeAmd)) op = this.opInt ();
	else if (this._obj.sizeAmd == AMDSize.SPREC) op = this.opFloat ();
	else if (this._obj.sizeAmd == AMDSize.DPREC) op = this.opFloat ();
	if (this._op == Tokens.SQRT) {
	    buf.writef ("\t%s%s\t%s, %s", op,
			this._obj.sizeAmd.id,
			this._obj.toString (),
			this._obj.toString ());
	} else if (this._op == Tokens.NOT) {
	    buf.writef ("\t%s%s\t$1, %s", op,
			this._obj.sizeAmd.id,
			this._obj.toString ());
	} else {
	    buf.writef ("\t%s%s\t%s", op, this._obj.sizeAmd.id, this._obj.toString ());
	}
	return buf.toString ();
    }
    
    
}

