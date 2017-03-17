module ast.Proto;
import ast.Declaration, syntax.Word, ast.Var, ast.Block;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;
import utils.exception, semantic.pack.ExternFrame;
import ast.Expression;

/**
 Classe généré à la syntaxe par.
 Example:
 ---
 'extern' ('(' Identifiant ')') Identifiant '(' var * ')' (':' type);
 ---
 */
class Proto : Declaration {

    /// L'identifiant du prototype
    private Word _ident;

    /// Le type de retour du prototype (peut être null)
    private Var _type;

    /// Les paramètres du prototype
    private Array!Var _params;

    /// 
    private Word _from;

    private bool _isVariadic;
    
    this (Word ident, Array!Var params, bool isVariadic) {
	this._ident = ident;
	this._params = params;
	this._isVariadic = isVariadic;
    }
    
    this (Word ident, Var type, Array!Var params, bool isVariadic) {
	this._ident = ident;
	this._type = type;
	this._params = params;
	this._isVariadic = isVariadic;
    }
    
    ref Word from () {
	return this._from;
    }

    /**
     Returns: Le type du prototype
     */
    Var type () {
	return this._type;
    }

    /**
     Returns: Les paramètres du prototype
     */
    Array!Var params () {
	return this._params;
    }

    /**
     Returns: L'identifiant du prototype
     */
    Word ident () {
	return this._ident;
    }

    /**
     Returns: le prototype est variadic
     */
    bool isVariadic () {
	return this._isVariadic;
    }
    
    /**
     Declare le prototype dans la table des symboles après vérification.
     Pour être juste le prototype ne doit contenir que des variable typé.
     Throws: NeedAllType, si il n'y a pas tout les types.
     */
    override void declare () {
	auto space = Table.instance.namespace ();
	foreach (it ; 0 .. this._params.length) {
	    if (cast (TypedVar) this._params [it] is null) {
		this._params [it] = new TypedVar (Word (this._params [it].token.locus, "_", false), this._params [it]);
	    }
	}
		
	auto fr = new ExternFrame (space, this._from.str, this);
	auto it = Table.instance.get (this._ident.str);
	if (it !is null) {
	    auto fun = cast (FunctionInfo) it.type;
	    fun.insert (fr);
	    Table.instance.insert (it);
	} else {
	    auto fun = new FunctionInfo (this._ident.str, space);
	    fun.insert (fr);
	    Table.instance.insert (new Symbol (this._ident, fun, true));
	}
	
    }

    /**
     Declare le prototype dans la table des symboles, si l'élément est déclaré comme publique.     
     */
    override void declareAsExtern () {
	if (this._isPublic) {
	    this.declare ();
	}
    }
    
    override Declaration templateReplace (Array!Var names, Array!Expression values) {
	Var type;
	if (this._type)
	    type = cast (Var) this._type.templateExpReplace (names, values);
	Array!Var params;
	foreach (it ; this._params)
	    params.insertBack(cast (Var) it.templateExpReplace (names, values));
	return new Proto (this._ident, type, params, this._isVariadic);
    }


}
