module ast.Function;
import ast.Declaration;
import syntax.Word;
import ast.Var, ast.Block, utils.exception;
import semantic.pack.FrameTable, semantic.pack.Table;
import semantic.pack.Frame, semantic.pack.UnPureFrame;
import semantic.types.FunctionInfo, semantic.pack.Symbol;
import std.container, std.stdio, std.string;
import semantic.pack.ExternFrame;
import semantic.pack.TemplateFrame;
import semantic.pack.PureFrame;
import ast.Expression;


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

    /// Les template de la fonction
    private Array!Expression _tmps;
    
    /// Le block de la fonction
    private Block _block;

    /// Le test a effectuer sur les paramètre templates
    private Expression _test;
    
    this (Word ident, Array!Var params, Array!Expression tmps, Expression test, Block block) {
	this._ident = ident;
	this._params = params;
	this._tmps = tmps;
	this._block = block;
	this.isPublic = true;
	this._test = test;
    }
    
    this (Word ident, Var type, Array!Var params, Array!Expression tmps, Expression test, Block block) {
	this._ident = ident;
	this._type = type;
	this._params = params;
	this._tmps = tmps;
	this._block = block;
	this.isPublic = true;
	this._test = test;
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
    ref Array!Var params () {
	return this._params;
    }

    ref Array!Expression tmps () {
	return this._tmps;
    }    

    Expression test () {
	return this._test;
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
	    FrameTable.instance.insert (new PureFrame (null, this));
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
		auto fun = new FunctionInfo (space, this._ident.str);
		fun.insert (fr);
		Table.instance.insert (new Symbol (this._ident, fun, true));
	    }
	}
    }

    /**
     Declare la fonction dans la table de symbol après vérification.
     Pour être correct la fonction doit avoir un identifiant jamais utilisé, ou alors par une autre fonction.
     Throws: ShadowingVar
     */
    override void declareAsInternal () {
	Frame fr = verifyPure ();
	fr.isInternal = true;
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
	    auto fun = new FunctionInfo (space, this._ident.str);
	    fun.insert (fr);
	    auto sym = new Symbol (this._ident, fun, true);
	    sym.isScoped = true;
	    Table.instance.insert (sym);
	}    
    }

       
    /**
     Declare une fonction dans la table des symboles après vérification.
     Pour être correct la fonction doit avoir un identifiant jamais utilisé, ou alors par une autre fonction.
     Throws: ShadowingVar
     */
    override void declareAsExtern () {
	if (this._ident.str != MAIN && this.isPublic) {
	    Frame fr = verifyPureAsExtern ();
	    auto space = Table.instance.namespace;
	    auto it = Table.instance.get (this._ident.str);
	    if (it !is null) {
		auto fun = cast (FunctionInfo) it.type;
		if (fun is null) throw new ShadowingVar (this._ident, it.sym);
		fun.insert (fr);
		Table.instance.insert (it);
	    } else {
		auto fun = new FunctionInfo (space, this._ident.str);
		fun.insert (fr);
		Table.instance.insert (new Symbol (this._ident, fun, true));
	    }
	}
    }

    /**
     Remplace les éléments template de la fonction 
     Returns: une nouvelle fonction avec les templates remplacé
     */
    override Function templateReplace (Expression [string] values) {
	Var type;
	if (this._type)
	    type = cast (Var) this._type.templateExpReplace (values);
	
	Array!Var params;
	foreach (it ; this._params) {
	    params.insertBack (cast (Var) it.templateExpReplace (values));
	}
	
	Expression test;
	if (this._test)
	    test = this._test.templateExpReplace (values);
	
	return new Function (this._ident, type, params, make!(Array!Expression), test, block.templateReplace (values));
    }    
    
    /**
     Verifie que la fonction est une fonction pure ou non.     
     */
    Frame verifyPure () {
	auto space = Table.instance.namespace ();
	if (this._tmps.length != 0) {
	    auto isPure = verifyTemplates ();
	    auto ret = new TemplateFrame (space, this);
	    if (!isPure) return ret;
	    foreach (it ; this._params)
		if (cast (TypedVar) it is null) return ret;

	    ret.isPure = true;
	    FrameTable.instance.insert (ret);
	    return ret;
	}
	foreach (it ; this._params) {
	    if (cast(TypedVar) (it) is null) return new UnPureFrame (space, this);
	    
	}
	auto fr = new PureFrame (space, this);
	FrameTable.instance.insert (fr);
	return fr;
    }

    bool verifyTemplates () {
	import ast.OfVar;
	bool isPure = true;
	foreach (it ; this._tmps) {
	    if (auto tvar = cast (TypedVar) it) {
		foreach (it_ ; this._params) {
		    if (auto _tvar_ = cast (TypedVar) it_) {
			if (_tvar_.type.token == tvar.token) {
			    throw new UseAsTemplateType (_tvar_.type.token, tvar.token);
			}
		    }
		}
		isPure = false;
	    } else if (cast (Var) it || cast (OfVar) it)
		isPure = false;
	    
	}
	return isPure;
    }
        
    /**
     Verifie que la fonction est une fonction pure ou non.     
     */
    Frame verifyPureAsExtern () {
	auto space = Table.instance.namespace ();
	if (this._tmps.length != 0) {
	    auto isPure = verifyTemplates ();
	    auto ret = new TemplateFrame (space, this);
	    if (!isPure) return ret;
	    foreach (it ; this._params)
		if (cast (TypedVar) it is null) return ret;

	    ret.isPure = true;
	    ret.isExtern = true;
	    FrameTable.instance.insert (ret);
	    return ret;	    
	}
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

    string name () {
	return this._ident.str;
    }

    void name (string other) {
	this._ident.str = other;
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
	    writefln("%s%s", rightJustify ("", nb + 4, ' '), it.prettyPrint);
	}

	this._block.print (nb + 4);
    }
    

}
