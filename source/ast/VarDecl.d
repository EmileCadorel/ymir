module ast.VarDecl;
import ast.Instruction, ast.Var, ast.Expression;
import std.container, syntax.Word, utils.YmirException;
import semantic.pack.Table, semantic.pack.Symbol;
import std.stdio, std.string, std.outbuffer;
import semantic.types.UndefInfo, utils.exception;

/**
 Cette classe est généré à la syntaxe par
 Example:
 ---
 'let' var ('=' expression)? (',' var ('=' expression)?)* ';'
 ---
 */
class VarDecl : Instruction {

    /// Les variables déclaré par l'instruction
    private Array!Var _decls;

    /// Les expressions à droite des variables déclarées.
    private Array!Expression _insts;
    
    this (Word word, Array!Var decls, Array!Expression insts) {
	super (word);
	this._decls = decls;
	this._insts = insts;
    }

    this (Word word) {
	super (word);
    }

    /**
     Vérification sémantique.
     Pour être correct, l'instruction ne doit déclarer que des variables qui n'existe pas.
     De plus les expressions droite doivent être correct et posséder un operateur d'affectation droite. (BinaryOpRight ('='));
     Throws: ErrorOccurs, si il y a eu des erreurs lors de l'analyse.
     */
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

    override VarDecl templateReplace (Array!Expression names, Array!Expression values) {
	Array!Expression insts;
	auto decls = this._decls.dup ();
	foreach (it ; this._insts) {	    
	    insts.insertBack (it.templateExpReplace (names, values));
	}
	
	return new VarDecl (this._token, decls, insts);
    }
    
    /**
     Returns: les expressions droites 
     */
    Array!Expression insts () {
	return this._insts;
    }

    /**
     Affiche l'instruction sous forme d'arbre
     Params:
     nb = l'offset courant
     */
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
