module ast.Cast;
import utils.Warning;
import ast.Expression;
import ast.Var;
import syntax.Word, utils.YmirException, utils.exception;
import semantic.pack.Symbol;


/**
 Classe généré par la syntaxe : 'cast' ':' type '(' exp ')'
 */
class Cast : Expression {

    /// Le type vers lequel on cast
    private Var _type;

    /// L'expression a caster
    private Expression _expr;

    this (Word begin, Var type, Expression expr) {
	super (begin);
	this._type = type;
	this._expr = expr;
    }

    override Expression expression () {
	auto type = this._type.asType ();
	auto expr = this._expr.expression ();
	if (cast (Type) expr) throw new UseAsVar (expr.token, expr.info);

	if (expr.info.type.isSame (type.info.type)) {
	    Warning.instance.warning_at (this._token.locus,
					 "L'element '%s%s%s', est déjà de type '%s%s%s'",
					 Colors.YELLOW.value,
					 expr.token.str,
					 Colors.RESET.value,
					 Colors.YELLOW.value,
					 type.info.type.typeString (),
					 Colors.RESET.value);

	    return expr;
	} else {
	    auto info = expr.info.type.CastOp (type.info.type);
	    if (info is null) {
		throw new UndefinedOp (this._token, expr.info, type.info);
	    } 
	    auto aux = new Cast (this._token, type, expr);
	    aux.info = new Symbol (this._token, info);
	    return aux;
	}
    }

    Expression expr () {
	return this._expr;
    }
    
}
