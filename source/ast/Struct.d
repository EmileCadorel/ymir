module ast.Struct;
import ast.Declaration;
import syntax.Word;
import ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;


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
	assert(false, "TODO");
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
