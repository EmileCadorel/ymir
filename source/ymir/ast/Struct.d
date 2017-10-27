module ymir.ast.Struct;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container, std.stdio, std.string;

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

    private Array!Expression _tmps;
    
    this (Word ident, Array!Expression tmps, Array!Var params) {
	this._ident = ident;
	this._params = params;
	this._tmps = tmps;
	this._isPublic = true;
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
	auto exist = Table.instance.getLocal (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {
	    auto str = new StructCstInfo (Table.instance.namespace, this._ident.str, this._tmps);
	    str.isPublic = true;
	    FrameTable.instance.insert (str);
	    auto sym = new Symbol(this._ident, str);
	    Table.instance.insert (sym);
	    foreach (it ; this._params) {
		if (auto ty = cast (TypedVar) it) {
		    str.addAttrib (ty);
		} else throw new NeedAllType (this._ident, "structure");		
	    }
	}
    }

    override void declareAsExtern (Module mod) {
	auto exist = mod.get (this._ident.str);
	if (exist) {
	    throw new ShadowingVar (this._ident, exist.sym);
	} else {	    
	    auto str = new StructCstInfo (mod.space, this._ident.str, this._tmps);
	    str.isExtern = this._tmps.length == 0;
	    str.isPublic = this._isPublic;
	    auto sym = new Symbol (this._ident, str);
	    sym.isPublic = this._isPublic;	    
	    
	    mod.insert (sym);
	    foreach (it ; this._params) {
		if (auto ty = cast (TypedVar) it) {
		    str.addAttrib (ty);
		} else throw new NeedAllType (this._ident, "structure");		
	    }	   
	}	
    }
    
    override Declaration templateReplace (Expression [string] values) {
	Array!Var params;
	foreach (it ; this._params)
	    params.insertBack (cast (Var) it.templateExpReplace (values));
	
	auto st = new Struct (this._ident, this._tmps, params);
	st._isPublic = this._isPublic;
	return st;
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
