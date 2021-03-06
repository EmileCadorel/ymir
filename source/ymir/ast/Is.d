module ymir.ast.Is;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container, std.stdio;

/**
 Classe généré par la syntaxe
 Example:
 --------
 'is' '(' exp ':' type ')'
 --------
*/
class Is : Expression {

    /// Le paramètre gauche
    private Expression _left;

    /// Le type à droite
    private Expression _type;

    private Word _expType;
    
    this (Word begin, Expression expr, Expression type) {
	super (begin);
	this._left = expr;
	this._type = type;
	this._left.inside = this;
	this._type.inside = this;
    }

    this (Word begin, Expression expr, Word type) {
	super (begin);
	this._left = expr;
	this._expType = type;
    }
    
    /**
     Vérification sémantique
     Pour être juste le type doit éxister et l'élément tester doit être typé
     Throw: UseAsType, UninitVar
     */
    override Expression expression () {
	if (this._type) {
	    auto aux = new Is (this._token, this._left.expression, this._type.expression);
	    if (!(cast (Type) aux._type) &&
		!(cast (StructCstInfo) aux._type.info.type) &&
		!aux._type.info.isType) throw new UseAsType (aux._type.token);
	    
	    if (cast (UndefInfo) aux._left.info.type) throw new UninitVar (aux._left.token);
	    
	    auto res = aux._left.info.type.isSame (aux._type.info.type);
	    auto type = new BoolInfo (true);
	    aux._info = new Symbol (this._token, type, true);
	    aux._info.value = new BoolValue (res);
	    return aux;	    
	} else {
	    auto aux = new Is (this._token, this._left.expression, this._expType);
	    if (cast (UndefInfo) aux._left.info.type) throw new UninitVar (aux._left.token);
	    auto type = new BoolInfo (true);
	    aux._info = new Symbol (this._token, type, true);
	    if (this._expType == Keys.FUNCTION) {
		aux._info.value = new BoolValue (
		    cast (FunctionInfo) (aux._left.info.type) !is null ||
		    cast (PtrFuncInfo) (aux._left.info.type) !is null
		);
	    } else if (this._expType == Keys.TUPLE) {
		aux._info.value = new BoolValue (
		    cast (TupleInfo) (aux._left.info.type) !is null
		);
	    } else {
		aux._info.value = new BoolValue (
		    cast (StructInfo) (aux._left.info.type) !is null ||
		    cast (StructCstInfo) (aux._left.info.type) !is null
		);
	    }
	    return aux;
	}
    }

    /**
     Remplace les templates par les expressions associés
     */
    override Expression templateExpReplace (Expression [string] values) {
	auto left = this._left.templateExpReplace (values);
	if (this._type) {
	    auto right = this._type.templateExpReplace (values);
	    return new Is (this._token, left, right);
	} else {
	    return new Is (this._token, left, this._expType);
	}
    }

    /**
     */
    override protected Expression onClone () {
	if (this._type) 
	    return new Is (this._token, this._left.clone (), this._type.clone ());
	else
	    return new Is (this._token, this._left.clone (), this._expType);
    }

    override string prettyPrint () {
	import std.format;
	if (this._type)
	    return format ("is (%s : %s)", this._left.prettyPrint, this._type.prettyPrint);
	else
	    return format ("is (%s : %s)", this._left.prettyPrint, this._expType.str);
    }
    
}
