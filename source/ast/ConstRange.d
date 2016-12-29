module ast.ConstRange;
import ast.Expression;
import std.container;
import semantic.types.InfoType;
import semantic.pack.Symbol;
import syntax.Word;
import ast.Var;
import semantic.types.FloatInfo, semantic.types.IntInfo;
import semantic.types.CharInfo, semantic.types.LongInfo;
import utils.exception;
import std.stdio, std.string;
import semantic.types.RangeInfo;

class ConstRange : Expression {

    private Expression _left;
    private Expression _right;
    private InfoType _content;
    private ubyte _lorr = 0;
    
    this (Word token, Expression left, Expression right) {
	super (token);
	this._left = left;
	this._right = right;
    }

    Expression left () {
	return this._left;
    }

    Expression right () {
	return this._right;
    }    

    ubyte lorr () {
	return this._lorr;
    }

    InfoType content () {
	return this._content;
    }
    
    override Expression expression () {
	auto aux = new ConstRange (this._token, this._left.expression, this._right.expression);
	auto type = aux._left.info.type.CompOp (aux._right.info.type);
	if (!cast (FloatInfo) type && !cast (IntInfo) type && !cast (CharInfo) type && !cast (LongInfo) type) {
	    throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	}
	
	if (!type.isSame (aux._left.info.type)) aux._lorr = 1;
	else if (!type.isSame (aux._right.info.type)) aux._lorr = 2;
	
	aux._content = type;
	aux._info = new Symbol (aux._token, new RangeInfo (type), true);
	return aux;
    }
    

}
