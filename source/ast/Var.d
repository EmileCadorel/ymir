module ast.Var;
import ast.Expression;
import syntax.Word, std.container;
import std.stdio, std.string;

class Var : Expression {

    private Array!Expression _templates;

    this (Word ident) {
	super (ident);
    }
    
    this (Word ident, Array!Expression templates) {
	super (ident);
	this._templates = templates;
    }

    void printSimple () {
	writef ("%s", this._token.str);
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Var> %s(%d, %d) %s ",
		  rightJustify ("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column,
		this._token.str);
    }
    
    
}

class TypedVar : Var {

    private Var _type;

    this (Word ident, Var type) {
	super (ident);
	this._type = type;
    }
    
    override void print (int nb = 0) {
	writef ("%s<TypedVar> %s(%d, %d) %s ",
		rightJustify ("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column,
		this._token.str);
	this._type.printSimple ();
	writeln ();
    }

}
