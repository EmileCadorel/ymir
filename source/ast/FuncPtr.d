module ast.FuncPtr;
import ast.Expression, std.container;
import ast.Var, syntax.Word;
import semantic.types.InfoType, semantic.pack.Symbol;
import syntax.Tokens, syntax.Keys, utils.exception;

class FuncPtr : Expression {

    private Array!Var _params;
    private Var _ret;
    private Expression _expr;

    this (Word begin, Array!Var params, Var type, Expression expr = null) {
	super (begin);
	this._params = params;
	this._ret = type;
	this._expr = expr;
    }

    Expression expr () {
	return this._expr;
    }
    
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
