module ast.Class;
import ast.Declaration;
import ast.Var, ast.Expression;
import syntax.Word;
import std.container;

class Class : Declaration {

    /** Les attributs de la classe */
    private Array!TypedVar _this;

    /** Les variables statique de la classe */
    private Array!TypedVar _static;

    /** Les paramètre templates de la classe */
    private Array!Expression _tmps;

    private Array!Declaration _cst;

    private Array!Declaration _dst;

    private Array!Declaration _decls;
    
    /** La classe parent */
    private Var _parent;

    /** L'identifiant de la classe */
    private Word _ident;
    
    this (Word ident, Var parent, Array!Expression tmps,
	  Array!TypedVar thisVars, Array!TypedVar staticVars,
	  Array!Declaration cst, Array!Declaration dst, Array!Declaration decls) {
	this._this = thisVars;
	this._static = staticVars;
	this._parent = parent;
	this._tmps = tmps;
	this._ident = ident;
	this._cst = cst;
	this._dst = dst;
	this._decls = decls;
    }
    
    override void declare () {
	assert (false, "TODO");
    }
    
}
