module ast.FuncPtr;
import ast.Expression, std.container;
import ast.Var, syntax.Word;
import semantic.types.InfoType, semantic.pack.Symbol;
import syntax.Tokens, syntax.Keys, utils.exception;

/**
 Classe genere par la syntaxe
 Example:
 ---
 'function' (type*) ':' type ('(' expression ')')?
 ---
*/
class FuncPtr : Expression {

    /// Les paramètre du pointeur sur fonction
    private Array!Var _params;

    /// Le type de retour du pointeur
    private Var _ret;

    /// Le contenu du pointeur (peut être null)
    private Expression _expr;

    this (Word begin, Array!Var params, Var type, Expression expr = null) {
	super (begin);
	this._params = params;
	this._ret = type;
	this._expr = expr;
    }

    /**
     Returns: l'expression contenu dans le pointeur (peut être null)
     */
    Expression expr () {
	return this._expr;
    }

    /**
     Vérification sémantique de l'expression.
     Pour être juste l'expression contenu doit être compatible avec le pointeur
     Throws: UndefinedOp, si le contenu n'est pas compatible.
     */
    override Expression expression () {
	Expression [] temp;
	temp.length = this._params.length + 1;
	temp [0] = this._ret.asType ();
	foreach (it ; 0 .. this._params.length) {
	    temp [it + 1] = this._params [it].asType ();
	}

	auto t_info = InfoType.factory (this._token, temp);	
	if (this._expr) {
	    auto aux = this._expr.expression ();
	    this._token.str = Tokens.EQUAL.descr;
	    auto ret = t_info.BinaryOp (this._token, aux);
	    if (ret is null) {
		throw new UndefinedOp (this._token, new Symbol (this._token, t_info), aux.info);
	    }
	    
	    this._token.str = Keys.FUNCTION.descr;	      
	    auto func = new FuncPtr (this._token, make!(Array!Var), null, aux);	    
	    func.info = new Symbol (this._token, ret);
	    return func;
	} else {
	    auto func = new FuncPtr (this._token, make!(Array!Var), null);
	    func.info = new Symbol (this._token, t_info);
	    return func;
	}
    }    

}
