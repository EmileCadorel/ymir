module ymir.dtarget.DVarDecl;
import ymir.dtarget._;

import std.container, std.algorithm;
import std.outbuffer, std.string;

final class DVarDecl : DInstruction {

    Array!DTypeVar _types;
    Array!DExpression _expr;
       
    void addVar (DTypeVar var) {
	this._types.insertBack (var);
    }

    void addExpression (DExpression expr) {
	this._expr.insertBack (expr);
    }

    override string toString () {
	auto buf = new OutBuffer ();
	foreach (it ; this._types) {
	    auto found = this._expr[].find!( (a, b) => (cast(DVar) (cast (DBinary)a).left).name == b.var.name) (it);
	    if (!found.empty) {
		if (it is this._types [0])
		    buf.writefln ("%s = %s;", it.toString, (cast (DBinary) found [0]).right.toString);
		else
		    buf.writefln ("%s%s = %s;",
				  rightJustify ("", this._father.nbIndent, ' '),
				  it.toString,
				  (cast (DBinary) found [0]).right.toString
		    );
	    } else {		
		if (it is this._types [0])
		    buf.writefln ("%s;", it.toString);
		else
		    buf.writefln ("%s%s;",
				  rightJustify ("", this._father.nbIndent, ' '),
				  it.toString);
	    }
	}	
	return buf.toString ();
    }    

}
