module ast.Struct;
import ast.Declaration;
import syntax.Word, utils.exception;
import ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;
import semantic.types.StructInfo, semantic.types.InfoType;


/**
 Classe généré par la syntaxe.
 Example:
 ---
 'struct' '(' var * ')' Identifiant ';'
 ---
 */
class Struct : Declaration {

    /// l'identifiant de la structure
    private Word _ident;

    /// Les paramètre de la srtucture
    private Array!Var _params;

    this (Word ident, Array!Var params) {
	this._ident = ident;
	this._params = params;
    }

    /**
     Returns: les paramètres de la structure
     */
    Array!Var params () {
	return this._params;
    }

    /**
     Returns: L'identifiant de la structure
     */
    Word ident () const {
	return this._ident;
    }

    /**
     Declare la structure après vérification.
     Pour être juste, la structure doit avoir un identifiant unique.
     Throws: ShadowingVar, NeedAllType
     */
    override void declare () {
	auto exist = Table.instance.get (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {
	    auto str = new StructCstInfo (this._ident.str);
	    auto sym = new Symbol(this._ident, str);
	    Table.instance.insert (sym);
	    InfoType.addCreator (this._ident.str);
	    foreach (it ; this._params) {
		if (auto ty = cast (TypedVar) it) {
		    str.addAttrib (ty);
		} else throw new NeedAllType (this._ident, "structure");		
	    }
	}
    }

    /**
     Affiche la structure sous forme d'arbre
     Params: 
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Struct> %s(%d, %d) %s",
		rightJustify ("", nb, ' '),
		this._ident.locus.file,
		this._ident.locus.line,
		this._ident.locus.column,
		this._ident.str);
	
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}
    }
               
}
