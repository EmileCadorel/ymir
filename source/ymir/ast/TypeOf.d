module ymir.ast.TypeOf;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container;
import std.stdio;

/**
 Classe généré par la syntaxe
 Example:
 --------
 'typeof' '(' exp ')'
 --------
*/
class TypeOf : Expression {

    /// Le paramètre de l'expression
    private Expression _expr;

    this (Word begin, Expression expr) {
	super (begin);
	this._expr = expr;
	this._expr.inside = this;
    }

    /**
     Vérification sémantique
     Pour être juste l'expression doit être typé et pas un type
     Throw: UseAsVar, UninitVar
     */
    override Expression expression () {
	auto expr = this._expr.expression ();
	if (cast (Type) expr) throw new UseAsVar (expr.token, expr.info);
	else if (cast (UndefInfo) expr.info.type) throw new UninitVar (expr.token);

	auto res = new Type (this._token, expr.info.type.clone ());
	res.info.type.isType = true;
	return res;	
    }

    override Expression templateExpReplace (Expression [string] values) {
	auto left = this._expr.templateExpReplace (values);
	return new TypeOf (this._token, left);
    }

    override protected Expression onClone () {
	auto info = new Symbol (this._token, this._info.type.clone ());
	auto ret = new TypeOf (this._token, this._expr.clone ());
	return ret;
    }

    override string prettyPrint () {
	import std.format;
	return format ("typeof (%s)", this._expr.prettyPrint ());
    }    

}
