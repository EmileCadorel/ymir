module ast.ParamList;
import ast.Expression;
import std.container, syntax.Word;
import std.stdio, std.string;

class ParamList : Expression {

    private Array!Expression _params;

    this (Word word, Array!Expression params) {
	super (word);
	this._params = params;
    }

    override void print (int nb = 0) {
	writefln ("%s<ParamList> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}
    }
    
}
