module ast.Block;
import ast.Instruction, ast.Declaration;
import syntax.Word, semantic.pack.Table;
import std.container, std.stdio, std.string, std.outbuffer;
import utils.exception, semantic.pack.Symbol;


/**
 * Suite d'instruction, ces instructions sont lu a la syntaxe
 * Example:
 * { (instruction | declaration)* }
*/
class Block : Instruction {

    private Array!Declaration _decls;
    private Array!Instruction _insts;
    private Array!Symbol _dest;
    
    this (Word word, Array!Declaration decls, Array!Instruction insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
    }
    
    Block instructions () {
	return this.block;
    }

    /**
     * Verification de la semantique
     */
    Block block () {
	Table.instance.enterBlock ();
	Array!Instruction insts;
	auto error = 0;
	auto block = new Block (this._token, make!(Array!Declaration), insts);
	//On declare tous les elements internes au block
	foreach (it ; this._decls) {
	    it.declare ();
	}

	foreach (it ; this._insts) {
	    try {
		if (Table.instance.retInfo.hasReturned ())
		    throw new UnreachableStmt (it.token);
		insts.insertBack (it.instruction);
		insts.back ().father = block;
	    } catch (YmirException exp) {
		exp.print ();
		error ++;
	    } catch (ErrorOccurs err) {
		error += err.nbError;
	    }
	}
	
	auto dest = Table.instance.quitBlock ();
	if (error > 0) throw new ErrorOccurs (error);
	block._insts = insts;
	block._dest = dest;
	return block;	
    }
    
    override Instruction instruction () {
	return this.instructions ();
    }

    ref Array!Symbol dest () {
	return this._dest;
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
