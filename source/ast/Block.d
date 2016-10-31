module ast.Block;
import ast.Instruction, ast.Declaration;
import syntax.Word, semantic.pack.Table;
import std.container, std.stdio, std.string, std.outbuffer;
import utils.exception;

class Block : Instruction {

    private Array!Declaration _decls;
    private Array!Instruction _insts;
    
    this (Word word, Array!Declaration decls, Array!Instruction insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
    }

    Block block () {
	Table.instance.enterBlock ();
	Array!Instruction insts;
	Array!Declaration decls;
	auto error = 0;
	foreach (it ; this._decls) {
	    it.declare ();
	}

	foreach (it ; this._insts) {
	    try {
		if (Table.instance.retInfo.has ("true"))
		    throw new UnreachableStmt (it.token);
		insts.insertBack (it.instruction);
	    } catch (YmirException exp) {
		exp.print ();
		error ++;
	    } catch (ErrorOccurs err) {
		error += err.nbError;
	    }
	}
	
	Table.instance.quitBlock ();
	if (error > 0) throw new ErrorOccurs (error);
	return new Block (this._token, decls, insts);
    }

    Array!Instruction insts () {
	return this._insts;
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
