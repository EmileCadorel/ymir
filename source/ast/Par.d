module ast.Par;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio, std.string;

class Par : Expression {

    private ParamList _params;
    private Expression _left;
    
    this (Word word, Expression left, ParamList params) {
	super (word);
	this._params = params;
	this._left = left;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Par> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._left.print (nb + 4);
	this._params.print (nb + 4);	
    }

}
