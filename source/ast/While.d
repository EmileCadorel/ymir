module ast.While;
import ast.Instruction, ast.Expression;
import ast.Block, syntax.Word;
import std.stdio, std.string;

class While : Instruction {

    private Expression _test;
    private Block _block;
    
    this (Word word, Expression test, Block block) {
	super (word);
	this._test = test;
	this._block = block;
    }

    override void print (int nb = 0) {
	writefln ("%s<While> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	
	this._test.print (nb + 4);
	this._block.print (nb + 4);
    }
    
}
