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

/**
 Classe généré à la syntaxe par.
 Example:
 ---
 expression '..' expression
 ---
 */
class ConstRange : Expression {

    /// l'élément de gauche
    private Expression _left;

    /// l'élément de droite
    private Expression _right;

    /// le type de l'expression
    private InfoType _content;

    private ubyte _lorr = 0;
    
    this (Word token, Expression left, Expression right) {
	super (token);
	this._left = left;
	this._right = right;
    }

    /**
     Returns: l'élément de gauche
     */
    Expression left () {
	return this._left;
    }

    /**
     Returns: l'élément de droite
     */
    Expression right () {
	return this._right;
    }    

    ubyte lorr () {
	return this._lorr;
    }

    /**
     Returns: l'information type du contenu
     */
    InfoType content () {
	return this._content;
    }

    /**
     Vérification sémantique.
     Pour être correct, gauche et droite doivent être compatible et de type que l'on peut mettre dans un Range.
     Throws: UndefinedOp
    */
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
