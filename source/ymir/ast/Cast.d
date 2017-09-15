module ymir.ast.Cast;
import ymir.utils._;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;

import std.container;

/**
 Classe généré par la syntaxe.
 Example:
 ---
 'cast' ':' type '(' exp ')'
 ---
 */
class Cast : Expression {

    /// Le type vers lequel on cast
    private Expression _type;

    /// L'expression a caster
    private Expression _expr;

    this (Word begin, Expression type, Expression expr) {
	super (begin);
	this._type = type;
	this._expr = expr;
	this._type.inside = this;
	this._expr.inside = this;
    }

    /**
     Vérification sémantique.
     Pour être juste le contenu doit surcharger l'operateur de 'cast' (CastOp) avec le bon type.
     Si le contenu est déjà du bon type, un warning est affiché, et le contenu est retourné.
     Throws: UseAsVar, si le contenu est un type, UndefinedOp.
     */
    override Expression expression () {
	auto type = this._type.expression ();
	auto expr = this._expr.expression ();
	if (cast (Type) expr) throw new UseAsVar (expr.token, expr.info);
	if (!cast (Type) type && !cast (FuncPtr) type)
	    if (!cast (ObjectCstInfo) type.info.type && !cast(StructCstInfo) type.info.type)
		throw new UseAsType (type.token);
	
	if (expr.info.type.isSame (type.info.type)) {
	    return expr;
	} else {
	    auto info = expr.info.type.CastOp (type.info.type);
	    if (info is null) {
		info = expr.info.type.CompOp (type.info.type);
		if (info is null)
		    throw new UndefinedOp (this._token, expr.info, type.info);
	    } 
	    auto aux = new Cast (this._token, type, expr);
	    aux.info = new Symbol (this._token, info);
	    return aux;
	}
    }
    
    override Expression templateExpReplace (Expression [string] values) {
	auto type = this._type.templateExpReplace (values);
	auto expr = this._expr.templateExpReplace (values);
	
	return new Cast (this._token, type, expr);
    }

    override Expression clone () {
	return new Cast (this._token, this._type.clone (), this._expr.clone ());
    }
    
    /**
     Returns: Le contenu de l'expression
     */
    Expression expr () {
	return this._expr;
    }
    
    override string prettyPrint () {
	import std.format;
	return format ("cast:%s (%s)", this._type.prettyPrint, this._expr.prettyPrint);
    }

}
