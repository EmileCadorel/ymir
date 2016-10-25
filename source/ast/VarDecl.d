module ast.VarDecl;
import ast.Instruction, ast.Var, ast.Expression;
import std.container, syntax.Word, utils.YmirException;
import semantic.pack.Table, semantic.pack.Symbol;
import std.stdio, std.string, std.outbuffer;
import semantic.types.UndefInfo;

class ShadowingVar : YmirException {
    this (Word token, Word token2) {
	OutBuffer buf = new OutBuffer;
	buf.writef ("%s:(%d,%d): ", token.locus.file, token.locus.line, token.locus.column);
	buf.writefln ("%sErreur%s : '%s%s%s' est déjâ definis ", Colors.RED.value, Colors.RESET.value, Colors.YELLOW.value, token.str, Colors.RESET.value);
	auto line = getLine (token.locus);
	buf.write (line);
	foreach (i ; 0 .. token.locus.column - 1) {
	    if (line[i] == '\t') buf.write ("\t");
	    else buf.write (" ");
	}
	
	foreach (it; 0 .. token.locus.length)
	    buf.write ("^");		
	buf.write ("\n");
	
	buf.writef ("%s:(%d,%d): ", token2.locus.file, token2.locus.line, token2.locus.column);
	buf.writefln ("%sNote%s : Première définition : ", Colors.BLUE.value, Colors.RESET.value);
	line = getLine (token2.locus);	
	buf.write (line);
	foreach (i ; 0 .. token2.locus.column - 1) {
	    if (line[i] == '\t') buf.write ("\t");
	    else buf.write (" ");
	}
	
	foreach (it; 0 .. token2.locus.length)
	    buf.write ("^");		
	buf.write ("\n");
	
	msg = buf.toString();        
    }
}


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
	foreach (it ; this._decls) {
	    auto aux = new Var (it.token);
	    auto info = Table.instance.get (it.token.str);
	    if (info !is null) throw new ShadowingVar (it.token, info.sym);
	    aux.info = new Symbol (aux.token, new UndefInfo ());
	    Table.instance.insert (aux.info);
	    auxDecl._decls.insertBack (aux);
	}
	auto error = 0;
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
