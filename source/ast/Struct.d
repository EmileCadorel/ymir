module ast.Struct;
import ast.Declaration;
import syntax.Word, utils.exception;
import ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;
import semantic.types.StructInfo;


class Struct : Declaration {

    private Word _ident;
    private Array!Var _params;

    this (Word ident, Array!Var params) {
	this._ident = ident;
	this._params = params;
    }

    Array!Var params () {
	return this._params;
    }

    Word ident () const {
	return this._ident;
    }
    
    override void declare () {
	auto exist = Table.instance.get (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {
	    auto str = new StructCstInfo (this._ident.str);
	    auto sym = new Symbol(this._ident, str);
	    Table.instance.insert (sym);
	    foreach (it ; this._params) {
		if (auto ty = cast (TypedVar) it) {
		    auto type = ty.getType ();
		    str.addAttrib (it.token.str, type);
		} else throw new NeedAllType (this._ident);		
	    }
	}
    }

    override void print (int nb = 0) {
	writefln ("%s<Struct> %s(%d, %d) %s",
		rightJustify ("", nb, ' '),
		this._ident.locus.file,
		this._ident.locus.line,
		this._ident.locus.column,
		this._ident.str);
	
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}
    }
               
}
