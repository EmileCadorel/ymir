module ast.Access;
import ast.Expression, ast.ParamList;
import syntax.Word, std.stdio, std.string;
import semantic.types.InfoType;
import ast.Var, utils.exception, semantic.types.UndefInfo;
import semantic.pack.Symbol, std.container;


/**
 Classe généré par la syntaxe : expression ('[' ParamList ']')

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

    /// Vérification sémantique
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

    /// Le getter de l'expression accédé
    Expression left () {
	return this._left;
    }

    /// le getter de paramètre de l'accés
    Array!Expression params () {
	return this._params.params;
    }
    
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
