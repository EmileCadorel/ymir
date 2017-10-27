module ymir.ast.Block;
import ymir.ast._;
import ymir.syntax._;
import ymir.semantic._;
import ymir.utils._;

import std.container, std.stdio, std.string, std.outbuffer;

/**
 * Suite d'instruction, ces instructions sont lu a la syntaxe
 * Example:
 ---
 { (instruction | declaration)* }
 ---
*/
class Block : Instruction {
    
    private Word _ident;
    private Array!Declaration _decls;
    private Array!Instruction _insts;
    
    this (Word word, Array!Declaration decls, Array!Instruction insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
	this._ident.setEof ();
    }

    /**
     Donne un identifiant de block
     */
    void setIdent (Word ident) {
	this._ident = ident;
    }

    /**
     Vérifications sémantique.
     */
    Block instructions () {
	return this.block;
    }

    /**
     * Verification sémantique
     Pour être juste toutes les instructions doivent être juste.
     Throws: ErrorOccurs.
     */
    Block block () {
	Table.instance.enterBlock ();
	scope (exit) Table.instance.quitBlock ();
	return blockWithoutEnter ();	
    }

    Block blockWithoutEnter () {
	if (!this._ident.isEof ()) 
	    Table.instance.retInfo.setIdent (this._ident);
	
	Array!Instruction insts;
	auto error = 0;
	auto block = new Block (this._token, make!(Array!Declaration), insts);
	
	//On declare tous les elements internes au block
	foreach (it ; this._decls) {
	    it.declareAsInternal ();
	}

	foreach (it ; this._insts) {
	    try {
		if (Table.instance.retInfo.hasReturned () ||
		    Table.instance.retInfo.hasBreaked ())
		    throw new UnreachableStmt (it.token);
		if (!cast (None) it) {
		    insts.insertBack (it.instruction);
		    insts.back ().father = block;
		}
	    } catch (RecursiveExpansion exp) {
		throw exp;
	    } catch (YmirException exp) {
		exp.print ();
		error ++;
		debug { writeln (exp); throw exp; }
	    } catch (ErrorOccurs err) {
		error += err.nbError;
		debug { throw err; }
	    }
	}
	if (error > 0) throw new ErrorOccurs (error);
	block._insts = insts;
	return block;	
    }
    

    override Block templateReplace (Expression [string] values) {
	Array!Declaration decls;
	Array!Instruction insts;
	foreach (it ; this._decls)
	    decls.insertBack (it.templateReplace (values));

	foreach (it ; this._insts)
	    insts.insertBack (it.templateReplace (values));

	return new Block (this._ident, decls, insts);
    }
    
    /**
     Vérification sémantique.
     */
    override Instruction instruction () {
	Table.instance.retInfo.currentBlock = "true";
	return this.instructions ();
    }

    /**
     Returns: la liste des instructions du block.
     */
    ref Array!Instruction insts () {
	return this._insts;
    }

    /**
     Affiche le block sous forme d'arbre.
     Params:
     nb = l'offset courant.
     */
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
