module ymir.ast.Unary;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.stdio, std.string, std.container;
import std.format;

/**
 Classe généré à la syntaxe pour les opérateurs unaires avant l'expression.
 Example:
 ---
 op (expression)
 ---
 */
class BefUnary : Expression {

    /// L'expression ou l'on va appliquer l'operateur
    private Expression _elem;
    
    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
	this._elem.inside = this;
    }

    /**
     Vérification sémantique.
     Pour être juste le type de l'élément doit surcharger l'operateur unaire (UnaryOp (op)).
     Throws: UndefinedVar, UninitVar, UndefinedOp.
     */
    override Expression expression () {
	if (this._info is null) {
	    auto aux = new BefUnary (this._token, this._elem.expression);
	    if (cast (Type) aux._elem !is null) throw new UseAsVar (aux._elem.token, aux._elem.info);
	    if (aux._elem.info.isType) throw new UseAsVar (aux._elem.token, aux._elem.info);
	    if (cast (UndefInfo) aux._elem.info.type !is null) throw new UninitVar (aux._elem.token);
	    auto type = aux._elem.info.type.UnaryOp (this._token);
	    if (type is null) {
		auto call = findOpUnary (aux);
		if (!call) 		
		    throw new UndefinedOp (this._token, aux._elem.info);
		else return call;
	    }
	    
	    aux._info = new Symbol (aux._token, type);
	    return aux;
	} else {	    
	    return this;	    
	}

    }

    private auto findOpUnary (BefUnary aux) {
	if (this._token != Tokens.AND) {
	    try {
		auto word = Word (this._token.locus, Keys.OPUNARY.descr, true);
		auto var = new Var (word, make!(Array!Expression) (new String (this._token, this._token.str)));		
		auto params = new ParamList (this._token,
					     make!(Array!Expression) (this._elem));
		auto call = new Par (this._token, this._token, var, params, true);
		return call.expression;
	    } catch (YmirException tm) {
		return null;
	    }
	} return null;
    }        

    override Expression templateExpReplace (Expression [string] values) {
	return new BefUnary (this._token, this._elem.templateExpReplace (values));
    }        
    
    override protected Expression onClone () {
	auto aux = new BefUnary (this._token, this._elem.clone ());
	aux.info = this._info;
	return aux;
    }

    /**
     Returns: l'élément de l'expression
     */
    Expression elem () {
	return this._elem;
    }

    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb = l'offset courant.
     */
    override void print (int nb = 0) {
	writefln ("%s<BefUnary> %s(%d, %d) %s",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	this._elem.print (nb + 4);    
    }

    override string prettyPrint () {
	return format ("%s%s", this._token.str, this._elem.prettyPrint);
    }   
    
}

/**
 Classe généré à la syntaxe pour les opérateurs unaire après l'expression.
 Example:
 ---
 (expression) op
 ---
 */
class AfUnary : Expression {

    /// L'élément ou l'on applique l'operateur 
    private Expression _elem;

    this (Word word, Expression elem) {
	super (word);
	this._elem = elem;
	this._elem.inside = this;
    }

    /**
     Vérification sémantique.
     Pour être juste l'élément doit surcharger l'operateur unaire (UnaryOp (op))
     Throws: UndefinedVar, UninitVar, UndefinedOp
     */
    override Expression expression () {
	auto aux = new BefUnary (this._token, this._elem.expression);
	if (cast (Type) aux._elem !is null) throw new UseAsVar (aux._elem.token, aux._elem.info);
	if (aux._elem.info.isType) throw new UseAsVar (aux._elem.token, aux._elem.info);
	
	if (cast (UndefInfo) aux._elem.info.type !is null) throw new UninitVar (aux._elem.token);
	auto type = aux._elem.info.type.UnaryOp (this._token);
	if (type is null) {
	    auto call = findOpUnary (aux);
	    if (!call)
		throw new UndefinedOp (this._token, aux._elem.info);
	    else return call;
	}
	
	aux._info = new Symbol (aux._token, type);
	return aux;
    }

    
    private auto findOpUnary (BefUnary aux) {
	if (this._token != Tokens.AND) {
	    try {
		auto word = Word (this._token.locus, Keys.OPUNARY.descr, true);
		auto var = new Var (word, make!(Array!Expression) (new String (this._token, this._token.str)));		
		auto params = new ParamList (this._token,
					     make!(Array!Expression) (this._elem));
		auto call = new Par (this._token, this._token, var, params, true);
		return call.expression;
	    } catch (YmirException tm) {
		return null;
	    }
	} return null;
    }
    
    override Expression templateExpReplace (Expression [string] values) {
	return new AfUnary (this._token, this._elem.templateExpReplace (values));
    }

    override protected Expression onClone () {
	return new AfUnary (this._token, this._elem.clone ());
    }

    Expression elem () {
	return this._elem;
    }
    
    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<AfUnary> %s(%d, %d) %s",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	this._elem.print (nb + 4);    
    }
    
    override string prettyPrint () {
	return format ("%s%s", this._elem.prettyPrint, this._token.str);
    }   
}
