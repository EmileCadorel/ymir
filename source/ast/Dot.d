module ast.Dot;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;
import std.string;


class Dot : Expression {

    private Expression _left;
    private Var _right;

    this (Word word, Expression left, Var right) {
	super (word);
	this._left = left;
	this._right = right;
    }

    this (Word word) {
	super (word);
    }

    override Expression expression () {
	auto aux = new Dot (this._token);
	aux._left = this._left.expression ();
	aux._right = this._right;
	if (cast (UndefInfo) (aux._left.info.type)) throw new UninitVar (aux._left.token);
	auto type = aux._left.info.type.DotOp (aux._right);
	if (type is null) {
	    throw new UndefinedAttribute (this._token, aux._left.info, aux._right);
	}
	aux.info = new Symbol (aux._token, type);
	return aux;
    }    

    Expression left () {
	return this._left;
    }

    Expression right () {
	return this._right;
    }
		      
    override void print (int nb = 0) {
	writefln ("%s<Dot> : %s(%d, %d) %s  ", rightJustify("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._left.print (nb + 4);
	this._right.print (nb + 4);
    }


}
