module ast.Function;
import ast.Declaration;
import syntax.Word;
import ast.Var, ast.Block, utils.exception;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;
import semantic.pack.ExternFrame;
import semantic.pack.PureFrame;


/**
 Classe généré à la syntaxe par.
 Example:
 ---
 'def' Identifiant '(' var * ')' (':' type) block
 ---
*/
class Function : Declaration {

    
    private static immutable string MAIN = "main";

    /// l'identifiant de la fonctions
    private Word _ident;

    /// le type de la fonction
    private Var _type = null;

    /// Les paramètre de la fonctions
    private Array!Var _params;

    /// Le block de la fonction
    private Block _block;

    this (Word ident, Array!Var params, Block block) {
	this._ident = ident;
	this._params = params;
	this._block = block;
    }
    
    this (Word ident, Var type, Array!Var params, Block block) {
	this._ident = ident;
	this._type = type;
	this._params = params;
	this._block = block;
    }

    /**
     Returns: Le type de la fonction
     */
    Var type () {
	return this._type;
    }

    /**
     Returns: les paramètres de la fonction
     */
    Array!Var params () {
	return this._params;
    }

    /**
     Returns: le block de la fonction
     */
    Block block () {
	return this._block;
    }

    /**
     Declare la fonction dans la table de symbol après vérification.
     Pour être correct la fonction doit avoir un identifiant jamais utilisé, ou alors par une autre fonction.
     Throws: ShadowingVar
     */
    override void declare () {
	if (this._ident.str == MAIN) {
	    FrameTable.instance.insert (new PureFrame ("", this));
	} else {
	    Frame fr = verifyPure ();
	    auto space = Table.instance.namespace ();

	    auto it = Table.instance.get (this._ident.str);
	    if (it !is null) {
		auto fun = cast (FunctionInfo) it.type;
		if (fun is null) {
		    throw new ShadowingVar (this._ident, it.sym);
		}
		fun.insert (fr);
		Table.instance.insert (it);
	    } else {
		auto fun = new FunctionInfo (this._ident.str, space);
		fun.insert (fr);
		Table.instance.insert (new Symbol (this._ident, fun, true));
	    }
	}
    }


    /**
     Declare une fonction dans la table des symboles après vérification.
     Pour être correct la fonction doit avoir un identifiant jamais utilisé, ou alors par une autre fonction.
     Throws: ShadowingVar
     */
    override void declareAsExtern () {
	if (this._ident.str != MAIN) {
	    Frame fr = verifyPureAsExtern ();
	    auto space = Table.instance.namespace;
	    auto it = Table.instance.get (this._ident.str);
	    if (it !is null) {
		auto fun = cast (FunctionInfo) it.type;
		if (fun is null) throw new ShadowingVar (this._ident, it.sym);
		fun.insert (fr);
		Table.instance.insert (it);
	    } else {
		auto fun = new FunctionInfo (this._ident.str, space);
		fun.insert (fr);
		Table.instance.insert (new Symbol (this._ident, fun, true));
	    }
	}
    }

    
    /**
     Verifie que la fonction est une fonction pure ou non.     
     */
    Frame verifyPure () {
	auto space = Table.instance.namespace ();
	foreach (it ; this._params) {
	    if (cast(TypedVar) (it) is null) return new UnPureFrame (space, this);
	    
	}
	auto fr = new PureFrame (space, this);
	FrameTable.instance.insert (fr);
	return fr;
    }

    /**
     Verifie que la fonction est une fonction pure ou non.     
     */
    Frame verifyPureAsExtern () {
	auto space = Table.instance.namespace ();
	foreach (it ; this._params) {
	    if (cast(TypedVar) (it) is null) return new UnPureFrame (space, this);
	    
	}
	auto fr = new ExternFrame (space, this);
	FrameTable.instance.insert (fr);
	return fr;
    }

    
    /**
     Returns: l'identifiant de la fonction
     */
    Word ident () const {
	return this._ident;
    }

    /**
     Affiche la fonction sous forme d'arbre
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writef ("%s<Function> %s(%d, %d) %s ",
		  rightJustify ("", nb, ' '), 
		  this._ident.locus.file,
		  this._ident.locus.line,
		  this._ident.locus.column,
		  this._ident.str);
	if (this._type !is null) {
	    this._type.printSimple ();
	}
	writeln ();
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}

	this._block.print (nb + 4);
    }
    

}
