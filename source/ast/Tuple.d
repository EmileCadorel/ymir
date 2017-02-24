module ast.Tuple;
import ast.Expression;
import syntax.Word, semantic.pack.Symbol, syntax.Keys;
import semantic.types.InfoType;
import std.container;
import semantic.types.VoidInfo;
import semantic.types.TupleInfo;
import ast.ParamList;

/**
Classe généré par la syntaxe:
Example:
----
'(' expression (',' expression) +')'
----
 */
class ConstTuple : Expression {

    private Word _end;
    private Array!Expression _params;
    
    this (Word word, Word end, Array!Expression params) {
	super (word);
	this._params = params;
    }
    
    Array!Expression params () {
	return this._params;
    }
    
    /**
     Vérification sémantique.
     Pour être correct, tout les éléments du tuples doivent être correct
     Returns: un autre tuple, vérifier sémantiquement
     */
    override Expression expression () {
	Array!Expression params;
	auto retType = new TupleInfo ();
	foreach (it ; this._params) {
	    auto expr = it.expression;
	    if (auto par = cast (ParamList) expr) {
		foreach (exp_it ; par.params) {
		    params.insertBack (exp_it);
		    retType.params.insertBack (params.back ().info.type);
		}
	    } else {
		params.insertBack (expr);
		retType.params.insertBack (params.back ().info.type);
	    }
	}
       	
	auto ret = new ConstTuple (this._token, this._end, params);
	
	ret.info = new Symbol (this._token, retType);
	return ret;
    }

    
}