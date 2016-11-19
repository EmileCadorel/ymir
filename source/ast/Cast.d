module ast.Cast;
import utils.Warning;
import ast.Expression;
import ast.Var;
import syntax.Word, utils.YmirException, utils.exception;
import semantic.pack.Symbol;

class Cast : Expression {
    
    private Var _type;
    private Expression _expr;

    this (Word begin, Var type, Expression expr) {
	super (begin);
	this._type = type;
	this._expr = expr;
    }

    override Expression expression () {
	auto type = this._type.asType ();
	auto expr = this._expr.expression ();
	auto info = expr.info.type.CastOp (type.info.type);
	if (info is expr.info.type) {
	    Warning.instance.warning_at (this._token.locus,
					 "L'element '%s%s%s', est déjà de type '%s%s%s'",
					 Colors.YELLOW.value,
					 expr.token.str,
					 Colors.RESET.value,
					 Colors.YELLOW.value,
					 info.typeString (),
					 Colors.RESET.value);
	   					
	} else if (info is null) {
	    throw new UndefinedOp (this._token, expr.info, type.info);
	}
	auto aux = new Cast (this._token, type, expr);
	aux.info = new Symbol (this._token, info, true);
	return aux;
    }

    Expression expr () {
	return this._expr;
    }
    
}
