module ast.Dot;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;
import std.string;

/**
 Classe généré à la syntaxe par.
 Example:
 ---
 expression '.' Identifiant
 ---
 */
class Dot : Expression {

    /// L'element de gauche de l'expression
    private Expression _left;

    /// L'element de droite de l'expression
    private Var _right;

    this (Word word, Expression left, Var right) {
	super (word);
	this._left = left;
	this._right = right;
    }

    this (Word word) {
	super (word);
    }

    /**
     Vérification sémantique.
     Pour être vrai, le type de l'élément de gauche doit surcharger l'operateur '.' (DotOp) avec l'element de droite.
     Throws: UndefinedAttribute.
     */
    override Expression expression () {
	auto aux = new Dot (this._token);
	aux._left = this._left.expression ();
	aux._right = this._right;
	if (cast (UndefInfo) (aux._left.info.type)) throw new UninitVar (aux._left.token);
	auto type = aux._left.info.type.DotOp (aux._right);
	if (type is null) {
	    if (InfoType.isPrimitive (aux._left.info.type)) 
		throw new UndefinedAttribute (this._token, aux._left.info, aux._right);
	    else {
		auto call = aux._right.expression ();
		if (cast (Type) call || cast (UndefInfo) call.info.type)
		    throw new UndefinedAttribute (this._token, aux._left.info, aux._right);
		return new DotCall (this._token, call, aux._left);
	    }
	}
	aux.info = new Symbol (aux._token, type);
	return aux;
    }    
    
    override Expression clone () {
	return new Dot (this._token, this._left.clone, cast (Var) this._right.clone ());
    }
    
    /**
     Returns: l'élément gauche de l'expression
     */
    Expression left () {
	return this._left;
    }
    
    /**
     Returns: l'élément droit de l'expression
     */
    Expression right () {
	return this._right;
    }

    override Expression templateExpReplace (Array!Var names, Array!Expression values) {
	return new Dot (this._token, this._left.templateExpReplace (names, values), cast (Var) this._right.clone ());
    }
    
    /**
     Affiche l'expression sous forme d'arbre
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Dot> : %s(%d, %d) %s  ", rightJustify("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);
	this._left.print (nb + 4);
	this._right.print (nb + 4);
    }


}

class DotCall : Expression {

    /** La fonction a appeler*/
    private Expression _call;

    /** Le premier paramètre de la fonction */
    private Expression _firstPar;

    this (Word token, Expression call, Expression firstPar) {
	super (token);
	this._call = call;
	this._firstPar = firstPar;
    }
       
    /**
     Returns: L'expression de l'appel
     */
    Expression call () {
	return this._call;
    }

    override Expression templateExpReplace (Array!Var, Array!Expression) {
	return this;
    }	
    
    /**
     Returns: le premier paramètre de l'appel
     */
    Expression firstPar () {
	return this._firstPar;
    }

    override Expression clone () {
	return new DotCall (this._token, this._call.clone (), this._firstPar.clone ());
    }
    
}
