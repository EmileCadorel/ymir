module ast.Class;
import ast.Declaration;
import ast.Var, ast.Expression;
import syntax.Word;
import std.container;
import semantic.pack.Table, semantic.pack.FrameTable;
import utils.exception;
import ast.Block;

class ClassDecl : Declaration {
    
    protected bool _private;

    protected bool _protected;

    this (bool pub, bool priv, bool prot) {
	this._isPublic = pub;
	this._private = priv;
	this._protected = prot;
    }

    final ref bool isPrivate () {
	return this._private;
    }

    final ref bool isProtected () {
	return this._protected;
    }
    
}

class Class : Declaration {

    /** Les attributs de la classe */
    private Array!TypedVar _this;

    /** Les variables statique de la classe */
    private Array!TypedVar _static;

    /** Les paramètre templates de la classe */
    private Array!Expression _tmps;

    private Array!Constructor _cst;

    private Array!Destructor _dst;

    private Array!ClassDecl _decls;
    
    /** La classe parent */
    private Var _parent;

    /** L'identifiant de la classe */
    private Word _ident;
    
    this (Word ident, Var parent, Array!Expression tmps,
	  Array!TypedVar thisVars, Array!TypedVar staticVars,
	  Array!Constructor cst, Array!Destructor dst, Array!ClassDecl decls) {
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
	auto exist = Table.instance.get (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {
	    if (this._dst.length > 1)
		throw new MultipleDestructor (this._ident, this._dst);
	    /*auto str = new ClassCstInfo (this._ident.str, this._tmps, this._cst, this._dst);	    	   
	      FrameTable.instance.insert (str);
	      auto sym = new Symbol (this._ident, str);
	    */
	}
    }
    
}

class Constructor : ClassDecl {

    /** Les paramètres du constructeur */
    private Array!Var _params;

    /** Le contenu du constructeur */
    private Block _block;

    private Word _ident;    
    
    this (Word ident, Array!Var params, Block block) {
	super (true, false, false);
	this._ident = ident;
	this._params = params;
	this._block = block;
    }

    override void declare () {}
}

class Destructor : ClassDecl {

    private Word _token;

    private Block _block;

    this (Word ident, Block block) {
	super (true, false, false);
	this._token = ident;
	this._block = block;
    }    
    
    override void declare () {}

    Word token () {
	return this._token;
    }
    
}

