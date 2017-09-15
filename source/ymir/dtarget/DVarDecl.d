module ymir.dtarget.DVarDecl;
import ymir.dtarget._;

import std.container;
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
	    if (it is this._types [0])
		buf.writefln ("%s;", it.toString);
	    else
		buf.writefln ("%s%s;",
			      rightJustify ("", this._father.nbIndent, ' '),
			      it.toString);
	}

	foreach (it ; this._expr) {
	    buf.writef ("%s%s;",
			rightJustify ("", this._father.nbIndent, ' '),
			it.toString);
	    if (it !is this._expr [$ - 1]) buf.writefln ("");
	}
	return buf.toString ();
    }    

}
