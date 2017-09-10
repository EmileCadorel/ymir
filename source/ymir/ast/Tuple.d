module ymir.ast.Tuple;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container;

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
	foreach (it ; this._params)
	    it.inside = this;
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

    
    override Expression templateExpReplace (Expression [string] values) {
	Array!Expression exprs;
	foreach (it ; this._params)
	    exprs.insertBack (it.templateExpReplace (values));
	
	return new ConstTuple (this._token, this._end, exprs);
    }

    override Expression clone () {
	Array!Expression exprs;
	exprs.length = this._params.length;
	foreach (it ; 0 .. this._params.length)
	    exprs [it] = this._params [it].clone ();
	return new ConstTuple (this._token, this._end, exprs);
    }

    override string prettyPrint () {
	import std.outbuffer;
	auto buf = new OutBuffer ();
	buf.writef ("tuple(");
	foreach (it ; this._params)
	    buf.writef ("%s%s", it.prettyPrint, it !is this._params [$ - 1] ? ", " : ")");
	return buf.toString;
    }
    
    
}
