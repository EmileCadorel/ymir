module ast.Function;
import ast.Declaration;
import syntax.Word;
import ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame;
import std.container, std.stdio, std.string;


class Function : Declaration {
    
    private immutable string MAIN = "main";
    private Word _ident;
    private Var _type = null;
    private Array!Var _params;
    private Block _block;

    this (Word ident, Array!Var params, Block block) {
	this._ident = ident;
	this._params = params;
	this._block = block;
    }
    
    this (Word ident, Var type, Array!Var params, Block block) {
	this._ident = ident;
	this._type = type;
	this._params = params;
	this._block = block;
    }

    Var type () {
	return this._type;
    }

    Array!Var params () {
	return this._params;
    }
    
    Block block () {
	return this._block;
    }

    override void declare () {
	if (this._ident.str == MAIN) {
	    FrameTable.instance.insert (new PureFrame ("", this));
	} else {
	    verifyPure ();
	}
    }

    void verifyPure () {
	auto space = Table.instance.namespace ();
	foreach (it ; this._params) {
	    if (cast(TypedVar) (it) is null) return;
	}
	FrameTable.instance.insert (new PureFrame (space, this));
    }
    
    Word ident () const {
	return this._ident;
    }
    
    override void print (int nb = 0) {
	writef ("%s<Function> %s(%d, %d) %s ",
		  rightJustify ("", nb, ' '), 
		  this._ident.locus.file,
		  this._ident.locus.line,
		  this._ident.locus.column,
		  this._ident.str);
	if (this._type !is null) {
	    this._type.printSimple ();
	}
	writeln ();
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}

	this._block.print (nb + 4);
    }
    

}
