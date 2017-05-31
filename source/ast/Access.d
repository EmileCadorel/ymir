module ast.Access;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio, std.string;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;
import semantic.pack.Table;
import ast.Par, syntax.Keys;

/**
 Classe généré par la syntaxe.
 Example:
 ---
 expression '[' ParamList ']'
 ---
*/
class Access : Expression {
    
    /// Le token qui contient le crochet fermant pour l'affichage d'erreur plus claire
    private Word _end; 

    /// Les paramètre contenu entre les crochets
    private ParamList _params;

    /// L'élement auquel on accède
    private Expression _left;

    this (Word word, Word end, Expression left, ParamList params) {
	super (word);
	this._end = end;
	this._params = params;
	this._left = left;
	this._left.inside = this;
	this._params.inside = this;
    }

    this (Word word, Word end) {
	super (word);
	this._end = end;
    }

    /**
     Vérification sémantique.
     L'element de gauche doit surcharger l'operateur '[]' (AccessOp) avec les élément de droite.
     Throws: UndefinedVar, si l'element de gauche n'existe pas.
     UninitVar, si l'element de gauche est de type indéfinis
     UndefinedOp, si l'operateur n'existe pas.
     */
    override Expression expression () {
	auto aux = new Access (this._token, this._end);
	aux._params = (cast(ParamList) this._params.expression ());
	aux._left = this._left.expression ();
	if (cast (Type) aux._left) throw new UndefinedVar (aux._left.token, Table.instance.getAlike (aux._left.token.str));
	else if (cast(UndefInfo) aux._left.info) throw new UninitVar (aux._left.token);
	else if (aux._left.info.isType) throw new UseAsVar (aux._left.token, aux._left.info);
	
	auto type = aux._left.info.type.AccessOp (aux._left.token, aux._params);
	if (type is null) {
	    auto call = findOpAccess (aux);
	    if (!call)
		throw new UndefinedOp (this._token, this._end, aux._left.info, aux._params);
	    else {
		//call.garbage ();
		return call;
	    }
	}
	aux._info = new Symbol (this._token, type);
	return aux;
    }

    auto findOpAccess (Access aux) {
	aux.removeGarbage ();
	try {	    
	    auto word = Word (this._token.locus, Keys.OPACCESS.descr, true);
	    auto var = new Var (word);
	    auto params = cast (ParamList) new ParamList (this._token,
							  make!(Array!Expression) (this._left) ~ this._params.params);

	    auto call = new Par (this._token, this._token, var, params, true);
	    return call.expression;
	} catch (YmirException tm) {
	    return null;
	}
    }
    

    
    override Expression templateExpReplace (Expression [string] values) {
	auto params = this._params.templateExpReplace (values);
	auto left = this._left.templateExpReplace (values);
	return new Access (this._token, this._end, left, params);
    }

    override Expression clone () {
	return new Access (this._token, this._end, this._left.clone (), cast (ParamList) this._params.clone ());
    }
    
    /**
     Returns: L'élément de gauche de l'expression
     */
    Expression left () {
	return this._left;
    }

    /**
     Returns: Les paramètres de l'expression
     */
    Array!Expression params () {
	return this._params.params;
    }

    override void removeGarbage () {
	if (this._info)
	    Table.instance.removeGarbage (this._info);
	if (this._params)
	    this._params.removeGarbage ();
	if (this._left)
	    this._left.removeGarbage ();
    }

    override void garbage () {
	super.garbage ();
	if (this._params)
	    this._params.garbage ();
	if (this._left)
	    this._left.garbage ();	
    }
    
    
    /**
     Affiche l'expression sous forme d'arbre
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Access>%s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._left.print (nb + 4);
	this._params.print (nb + 4);
    }

    override string prettyPrint () {
	import std.format;
	return format ("%s [%s]", this._left.prettyPrint, this._params.prettyPrint);
    }
    
    
    

}
