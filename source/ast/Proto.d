module ast.Proto;
import ast.Declaration, syntax.Word, ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;
import utils.exception, semantic.pack.ExternFrame;


class Proto : Declaration {

    private Word _ident;
    private Var _type;
    private Array!Var _params;
    private Word _from;
    
    this (Word ident, Array!Var params) {
	this._ident = ident;
	this._params = params;
    }
    
    this (Word ident, Var type, Array!Var params) {
	this._ident = ident;
	this._type = type;
	this._params = params;
    }
    
    ref Word from () {
	return this._from;
    }

    Var type () {
	return this._type;
    }

    Array!Var params () {
	return this._params;
    }

    Word ident () {
	return this._ident;
    }
    
    override void declare () {
	auto space = Table.instance.namespace ();
	foreach (it ; this._params) {
	    if (cast (TypedVar) it is null) {
		throw new NeedAllType (this._ident);
	    }
	}
	
	
	auto fr = new ExternFrame (space, this._from.str, this);
	auto it = Table.instance.get (this._ident.str);
	if (it !is null) {
	    auto fun = cast (FunctionInfo) it.type;
	    fun.insert (fr);
	    Table.instance.insert (it);
	} else {
	    auto fun = new FunctionInfo (this._ident.str, space);
	    fun.insert (fr);
	    Table.instance.insert (new Symbol (this._ident, fun, true));
	}
	
    }

    
}
