module ast.Expand;
import ast.Expression;
import ast.Var;
import syntax.Word, utils.YmirException, utils.exception;
import semantic.pack.Symbol;
import semantic.types.TupleInfo;
import semantic.types.UndefInfo;
import std.container;
import ast.ParamList;

/**
 Classe généré par la syntaxe
 Example:
 ---
 'expand' '(' exp ')'
 ----
 */
class Expand : Expression {

    /** Le paramètre de l'expand */
    private Expression _expr;

    /** Le debut de l'expand */
    private ulong _index;

    this (Word begin, Expression expr) {
	super (begin);
	this._expr = expr;
    }

    this (Word begin, Expression expr, ulong index) {
	super (begin);
	this._expr = expr;
	this._index = index;
    }
    
    /**
     Vérification sémantique.
     Pour être juste le contenu doit surcharger doit être de type tuple.
     Throws: UseAsVar, si le contenu est un type
     */
    override Expression expression () {
	auto expr = this._expr.expression ();
	if (cast (Type) expr) throw new UseAsVar (expr.token, expr.info);
	if (!cast (TupleInfo) (expr.info.type)) return expr;
	Array!Expression params;	
	auto tuple = cast(TupleInfo) expr.info.type;
	
	foreach (it ; 0 .. tuple.params.length) {
	    auto exp = new Expand (this._token, expr, it);
	    exp.info = new Symbol (false, exp.token, tuple.params[it].clone);
	    params.insertBack (exp);
	}

	auto aux = new ParamList (this._token, params);	
	aux.info = new Symbol (this._token, new UndefInfo ());
	return aux;
    }

    override Expression templateExpReplace (Array!Var names, Array!Expression values) {
	auto expr = this._expr.templateExpReplace (names, values);
	return new Expand (this._token, expr);
    }

    override Expression clone () {
	return new Expand (this._token, this._expr.clone ());
    }
    
    /**
     Returns: le contenu étendue.
     */
    Expression expr () {
	return this._expr;
    }    

    ulong index () {
	return this._index;
    }


    
}
