module ast.Access;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio, std.string;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;


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
	if (cast (Type) aux._left) throw new UndefinedVar (aux._left.token);
	else if (cast(UndefInfo) aux._left.info) throw new UninitVar (aux._left.token);

	auto type = aux._left.info.type.AccessOp (aux._left.token, aux._params);
	if (type is null)
	    throw new UndefinedOp (this._token, this._end, aux._left.info, aux._params);
	aux._info = new Symbol (this._token, type);
	return aux;
    }

    
    override Expression templateExpReplace (Array!Var names, Array!Expression values) {
	auto params = this._params.templateExpReplace (names, values);
	auto left = this._left.templateExpReplace (names, values);
	return new Access (this._token, this._end, left, params);
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
    
    
    

}
