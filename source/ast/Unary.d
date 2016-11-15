module ast.Unary;
import ast.Expression;
import syntax.Word;
import std.stdio, std.string;

class BefUnary : Expression {

    private Expression _elem;
    
    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<BefUnary> %s(%d, %d) %s",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	this._elem.print (nb + 4);    
    }

    
}

class AfUnary : Expression {

    private Expression _elem;

    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<AfUnary> %s(%d, %d) %s",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	this._elem.print (nb + 4);    
    }    
}
