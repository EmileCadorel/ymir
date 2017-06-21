module ast.Trait;
import syntax.Word, utils.exception;
import ast.all;
import semantic.pack.Table, semantic.pack.Symbol;
import std.container;
import trait = semantic.impl.Trait;


class Trait : Declaration {

    private Array!TraitProto _prototypes;

    private Word _ident;
    
    this (Word ident, Array!TraitProto meth) {
	this._ident = ident;
	this._prototypes = meth;
    }
    
    override void declare () {
	auto space = Table.instance.namespace;
	if (auto it = Table.instance.getLocal (this._ident.str))
	    throw new ShadowingVar (this._ident, it.sym);

	Table.instance.insert (new Symbol (this._ident, new trait.TraitObj (this._ident, space, this._prototypes), true));
    }
    
}

class TraitProto : Declaration {

    private Array!Var _params;

    private Var _type;

    private Word _ident;

    this (Word ident, Array!Var params, Var type) {
	this._ident = ident;
	this._params = params;
	this._type = type;
    }

    override void declare () {}
        
}

