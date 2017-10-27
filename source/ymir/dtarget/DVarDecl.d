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
	if (auto bin = cast (DBinary) expr) {
	    if (!bin.right) assert (false);
	    this._expr.insertBack (expr);
	} else assert (false);
    }

    string inOneLine () {
	auto buf = new OutBuffer ();
	foreach (it ; this._types) {
	    auto found = this._expr[].find!( (a, b) => (cast(DVar) (cast (DBinary)a).left).name == b.var.name) (it);
	    if (!found.empty) {
		buf.writef ("%s = %s", it.toString, (cast (DBinary) found [0]).right.toString);
	    } else {		
		buf.writef ("%s", it.toString);
	    }
	    if (it !is this._types [$ - 1]) buf.write (", ");	    
	}
	return buf.toString;
    }
    
    override string toString () {
	auto nbIndent = this._father ? this._father.nbIndent : 0;
	auto buf = new OutBuffer ();
	foreach (it ; this._types) {
	    auto found = this._expr[].find!( (a, b) {
		    import std.stdio;
		    auto bin = cast (DBinary) a;
		    if (bin) {
			auto var = cast (DVar) bin.left;
			if (!var) writeln ("ICI : ", a);
			return b.var.name == var.name;
		    } else {
			writeln ("ICI : ", a);
		    }
		    assert (false);
		}) (it);
	    if (!found.empty) {
		if (it is this._types [0])
		    buf.writefln ("%s = %s;", it.toString, (cast (DBinary) found [0]).right.toString);
		else
		    buf.writefln ("%s%s = %s;",
				  rightJustify ("", nbIndent, ' '),
				  it.toString,
				  (cast (DBinary) found [0]).right.toString
		    );
	    } else {		
		if (it is this._types [0])
		    buf.writefln ("%s;", it.toString);
		else
		    buf.writefln ("%s%s;",
				  rightJustify ("", nbIndent, ' '),
				  it.toString);
	    }
	}	
	return buf.toString ();
    }    

}
