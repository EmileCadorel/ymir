module ast.Block;
import ast.Instruction, ast.Declaration;
import syntax.Word;
import std.container, std.stdio, std.string;

class Block : Instruction {

    private Array!Declaration _decls;
    private Array!Instruction _insts;
    
    this (Word word, Array!Declaration decls, Array!Instruction insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
    }

    Block block () {
	assert (false, "TODO");
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Block> : %s(%d, %d) ", rightJustify ("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column);
	foreach (it ; this._decls)
	    it.print (nb + 4);
	foreach (it ; this._insts)
	    it.print (nb + 4);
    }

    
}
