module ast.Function;
import ast.Declaration;
import syntax.Word;
import ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
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
	    Frame fr = verifyPure ();
	    auto space = Table.instance.namespace ();

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

    Frame verifyPure () {
	auto space = Table.instance.namespace ();
	foreach (it ; this._params) {
	    if (cast(TypedVar) (it) is null) return new UnPureFrame (space, this);
	    
	}
	auto fr = new PureFrame (space, this);
	FrameTable.instance.insert (fr);
	return fr;
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
