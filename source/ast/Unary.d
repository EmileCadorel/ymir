module ast.Unary;
import ast.Expression;
import ast.Var;
import syntax.Word, semantic.types.InfoType;
import semantic.types.UndefInfo, utils.exception;
import std.stdio, std.string, semantic.pack.Symbol;
import std.container;
import semantic.pack.Table;

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
    }

    /**
     Vérification sémantique.
     Pour être juste le type de l'élément doit surcharger l'operateur unaire (UnaryOp (op)).
     Throws: UndefinedVar, UninitVar, UndefinedOp.
     */
    override Expression expression () {
	auto aux = new BefUnary (this._token, this._elem.expression);
	if (cast (Type) aux._elem !is null) throw new UndefinedVar (aux._elem.token, Table.instance.getAlike (aux._elem.token.str));
	if (cast (UndefInfo) aux._elem.info.type !is null) throw new UninitVar (aux._elem.token);
	auto type = aux._elem.info.type.UnaryOp (this._token);
	if (type is null) {
	    throw new UndefinedOp (this._token, aux._elem.info);
	}
	
	aux._info = new Symbol (aux._token, type);
	return aux;
    }

    override void removeGarbage () {
	super.removeGarbage ();
	if (this._elem)
	    this._elem.removeGarbage ();
    }
    
    override void garbage () {
	super.garbage ();
	if (this._elem)
	    this._elem.garbage ();
    }
    

    override Expression templateExpReplace (Array!Var names, Array!Expression values) {
	return new BefUnary (this._token, this._elem.templateExpReplace (names, values));
    }        
    
    override Expression clone () {
	return new BefUnary (this._token, this._elem.clone ());
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
    }

    /**
     Vérification sémantique.
     Pour être juste l'élément doit surcharger l'operateur unaire (UnaryOp (op))
     Throws: UndefinedVar, UninitVar, UndefinedOp
     */
    override Expression expression () {
	auto aux = new BefUnary (this._token, this._elem.expression);
	if (cast (Type) aux._elem !is null) throw new UndefinedVar (aux._elem.token, Table.instance.getAlike (aux._elem.token.str));
	if (cast (UndefInfo) aux._elem.info.type !is null) throw new UninitVar (aux._elem.token);
	auto type = aux._elem.info.type.UnaryOp (this._token);
	if (type is null) {
	    throw new UndefinedOp (this._token, aux._elem.info);
	}
	
	aux._info = new Symbol (aux._token, type);
	return aux;
    }

    override Expression templateExpReplace (Array!Var names, Array!Expression values) {
	return new AfUnary (this._token, this._elem.templateExpReplace (names, values));
    }

    override Expression clone () {
	return new AfUnary (this._token, this._elem.clone ());
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
}
