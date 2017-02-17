module ast.Expand;
import ast.Expression;
import ast.Var;
import syntax.Word, utils.YmirException, utils.exception;
import semantic.pack.Symbol;
import semantic.types.TupleInfo;
import std.container;

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

    /** Les parametre développés. */
    private Array!Expression _types; 

    /** Le debut de l'expand */
    private ulong _index;

    this (Word begin, Expression expr) {
	super (begin);
	this._expr = expr;
    }

    this (Word begin, Expression expr, Array!Expression params, ulong index) {
	super (begin);
	this._expr = expr;
	this._types = params;
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
	auto aux = new Expand (this._token, expr);
	auto tuple = cast (TupleInfo) expr.info.type;
	Array!Expression params;	
	
	foreach (it ; tuple.params) {
	    auto var = new Var (Word (this._token.locus, "_", false));
	    var.info = new Symbol (false, var.token, it);
	    params.insertBack (var);
	}
	aux._types = params;
	
	return aux;
    }

    /**
     Returns: Les types contenu dans le tuple qui va etre étendue.     
     */
    Array!Expression params () {
	return this._types;
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
