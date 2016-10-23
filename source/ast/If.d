module ast.If;
import ast.Instruction;
import ast.Expression, ast.Block;
import syntax.Word, std.stdio, std.string;

class If : Instruction {

    private Expression _test;
    private Block _block;
    private Else _else;
    
    this (Word word, Expression test, Block block) {
	super (word);
	this._test = test;
	this._block = block;
    }

    this (Word word, Expression test, Block block, Else else_) {
	super (word);
	this._test = test;
	this._block = block;
	this._else = else_;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<If> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._test.print (nb + 4);
	this._block.print (nb + 4);
	if (this._else !is null)
	    this._else.print (nb);
    }


}

class Else : Instruction {
    private Block _block;

    this (Word word, Block block) {
	super (word);
	this._block = block;
    }
    
    override void print (int nb = 0) {
	writefln ("%s<Else> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._block.print (nb + 4);	
    }
    
}

class ElseIf : Else {

    private Expression _test;
    private Else _else;
    
    this (Word word, Expression test, Block block) {
	super (word, block);
	this._test = test;
    }

    this (Word word, Expression test, Block block, Else else_) {
	super (word, block);
	this._test = test;
	this._else = else_;
    }	

    override void print (int nb = 0) {
	writefln ("%s<ElseIf> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	this._test.print (nb + 4);
	this._block.print (nb + 4);
	if (this._else !is null)
	    this._else.print (nb);
    }
    
}
