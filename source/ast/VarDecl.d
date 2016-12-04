module ast.VarDecl;
import ast.Instruction, ast.Var, ast.Expression;
import std.container, syntax.Word, utils.YmirException;
import semantic.pack.Table, semantic.pack.Symbol;
import std.stdio, std.string, std.outbuffer;
import semantic.types.UndefInfo, utils.exception;


class VarDecl : Instruction {

    private Array!Var _decls;
    private Array!Expression _insts;
    
    this (Word word, Array!Var decls, Array!Expression insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
    }

    this (Word word) {
	super (word);
    }
    
    override Instruction instruction () {
	auto auxDecl = new VarDecl (this._token);
	auto error = 0;
	foreach (it ; this._decls) {
	    try {
		auto aux = new Var (it.token);
		auto info = Table.instance.get (it.token.str);
		if (info !is null) throw new ShadowingVar (it.token, info.sym);
		aux.info = new Symbol (aux.token, new UndefInfo ());
		aux.info.isConst = false;
		Table.instance.insert (aux.info);
		auxDecl._decls.insertBack (aux);
	    } catch (YmirException exp) {
		exp.print ();
		error ++;
	    } catch (ErrorOccurs err) {
		error += err.nbError;
	    }
	}

	foreach (it ; this._insts) {
	    try {
		auxDecl._insts.insertBack (it.expression ());
	    } catch (YmirException exp) {
		exp.print ();
		error ++;
	    } catch (ErrorOccurs err) {
		error += err.nbError;
	    }
	}

	if (error > 0) throw new ErrorOccurs (error);	
	return auxDecl;
    }

    Array!Expression insts () {
	return this._insts;
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
