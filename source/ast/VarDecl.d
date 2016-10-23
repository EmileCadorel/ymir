module ast.VarDecl;
import ast.Instruction, ast.Var, ast.Expression;
import std.container, syntax.Word;
import std.stdio, std.string;

class VarDecl : Instruction {

    private Array!Var _decls;
    private Array!Expression _insts;
    
    this (Word word, Array!Var decls, Array!Expression insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
    }

    override void print (int nb = 0) {
	writefln ("%s<VarDecl> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	
	foreach (it; this._decls) {
	    it.print (nb + 4);
	}

	foreach (it ; this._insts) {
	    it.print (nb + 4);
	}
    }
    
}
