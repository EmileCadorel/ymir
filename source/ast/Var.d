module ast.Var;
import ast.Expression, semantic.pack.Table;
import syntax.Word, std.container, semantic.types.InfoType;
import std.stdio, std.string, std.outbuffer, utils.YmirException;
import semantic.pack.Symbol, ast.Constante;
import utils.exception;
import semantic.types.ArrayInfo;
import ast.FuncPtr, semantic.types.TupleInfo;
import semantic.pack.Table;
import syntax.Keys, semantic.types.RefInfo;
import semantic.impl.ObjectInfo;
import semantic.types.EnumInfo;
import semantic.types.StructInfo;
import ast.Par, ast.ParamList, ast.Dot;
import ast.OfVar, std.conv;

/**
 Une variable est généré à la syntaxe par un identifiant.
 Example:
 ---
 foo
 test_de_variable
 type!(10, int)
 // ...
 ---
 */
class Var : Expression {

    /// Les arguments templates de la variable
    private Array!Expression _templates;

    /// L'élément de décoration de la variable (const, ref)
    protected Word _deco;

    this (Word ident) {
	super (ident);
    }
    
    this (Word ident, Word deco) {
	super (ident);
	this._deco = deco;
    }
    
    this (Word ident, Array!Expression templates) {
	super (ident);
	this._templates = templates;
	foreach (it ; this._templates)
	    it.inside = this;
    }

    /**
     Affiche la variable sur une seule ligne
     */
    override void printSimple () {
	writef ("%s!(", this._token.str);
	foreach (it ; this._templates) {
	    it.printSimple ();
	}
	writef (")");
    }    
    
    /**
     Vérification sémantique.
     Pour être juste le symbole de l'identifiant doit exister.
     Il peut être un type, une fonction, une structure ...
     Throws: UndefinedVar, si l'identifiant n'existe pas
     */
    override Expression expression () {
	if (this._info && this._info.isImmutable)
	    return this;
	if (!isType) {
	    auto aux = new Var (this._token);
	    aux.info = Table.instance.get (this._token.str);
	    if (aux.info is null) 
		throw new UndefinedVar (this._token, Table.instance.getAlike (this._token.str));
	    
	    if (this._templates.length != 0) {		
		if (!cast (Par) this._inside && !cast (Dot) this._inside) {
		    auto params = new ParamList (this._token, make!(Array!Expression));
		    auto call = new Par (this._token, this._token, this, params, true);
		    this._inside = call;
		    return call.expression;
		} else if (auto dt = cast (Dot) this._inside) {
		    if (this is dt.left) {
			auto params = new ParamList (this._token, make!(Array!Expression));
			auto call = new Par (this._token, this._token, this, params, true);
			this._inside = call;
			return call.expression;
		    }
		}
		
		auto id = aux.info.id;
		Array!Expression tmps;
		foreach (it ; this._templates) {
		    tmps.insertBack (it.expression ());
		}
		
		auto type = aux.info.type.TempOp (tmps);
		if (type is null)
		    throw new NotATemplate (this._token, tmps);
		
		aux.templates = tmps;
		aux.info = new Symbol (aux.info.sym, type, true);		
	    }
	    return aux;	
	} else return asType ();
    }

    /**
     Vérification sémantique.
     Pour être juste le symbole de l'identifiant doit éxister.
     Il peut être un type, une fonction, une structure ...
     Throws: UndefinedVar, si l'identifiant n'existe pas
     */
    Var var () {
	if (this._info && this._info.isImmutable)
	    return this;
	if (!isType) {
	    auto aux = new Var (this._token);	    
	    aux.info = Table.instance.get (this._token.str);
	    if (aux.info is null) 
		throw new UndefinedVar (this._token, Table.instance.getAlike (this._token.str));
	    
	    if (this._templates.length != 0) {
		auto id = aux.info.id;
		Array!Expression tmps;
		foreach (it ; this._templates) {
		    tmps.insertBack (it.expression ());
		}
		
		auto type = aux.info.type.TempOp (tmps);
		if (type is null)
		    throw new NotATemplate (this._token, tmps);
		
		aux.templates = tmps;
		aux.info = new Symbol (aux.info.sym, type, true);	
	    }
	    return aux;	
	} else return asType ();
    }    
        
    override Expression templateExpReplace (Expression [string] values) {
	foreach (key, value ; values) {
	    if (key == this._token.str) {		
		auto clo = value.clone ();
		/*if (!cast (Decimal) clo)
		 clo.token = this._token;*/
		if (auto v = cast (Var) clo) {
		    v.deco = this._deco;
		}
		clo.token.locus = this._token.locus;
		return clo;
	    }
	}

	Array!Expression tmps;
	foreach (it ; this._templates) {
	    auto ret = it.templateExpReplace (values);
	    if (auto vvar = cast (VariadicSoluce) ret) {
		foreach (_it ; 0 .. vvar.types.length) {
		    auto word = Word (it.token.locus, it.token.str ~ "_" ~ to!string (_it), false);
		    tmps.insertBack (new Type (word, vvar.types [_it]));
		}
	    } else 
		tmps.insertBack (ret);
	}
	
	auto ret =  new Var (this._token, tmps);
	ret.deco = this._deco;
	return ret;
    }
    
    /**
     Met à jour le type de la variable
     Params:
     info = le symbole du type à affecter à la variable
     */
    TypedVar setType (Symbol info) {
	if (this._deco == Keys.REF) {
	    auto type = new Type (info.sym, info.type.cloneForParam ());
	    return new TypedVar (this._token, type);
	} else {
	    auto type = new Type (info.sym, info.type.cloneForParam ());
	    return new TypedVar (this._token, type, this._deco);
	}
    }

    /**
     Met à jour le type de la variable
     Params:
     info = l'information du type à affecter à la variable
     */
    TypedVar setType (InfoType info) {
	if (this._deco == Keys.REF) {
	    auto type = new Type (this._token, info.cloneForParam ());
	    return new TypedVar (this._token, type);
	} else {
	    auto type = new Type (this._token, info.cloneForParam ());
	    return new TypedVar (this._token, type, this._deco);
	}
    }    

    /**
     Vérification sémantique.
     Pour être juste la variable doit être un type.
     Throws: UseAsType, si le type n'existe pas.
     */
    Type asType () {
	import std.array;
	Array!Expression temp;
	foreach (it ; this._templates) {
	    temp.insertBack (it.expression);
	}
	if (!InfoType.exist (this._token.str)) {
	    auto en = Table.instance.get (this._token.str);
	    if (en !is null) {
		if (auto encst = cast (EnumCstInfo) en.type) {
		    if (temp.length != 0) throw new UseAsType (this._token);
		    if (this._deco == Keys.REF) 
			throw new CannotRefEnum (this._token);
		    else return new Type (this._token, encst.create ());	    
		} else if (auto str = cast (StructCstInfo) en.type) {
		    auto type = str.create (this._token, temp.array ());
		    if (this._deco == Keys.REF)
			return new Type (this._token, new RefInfo (type));
		    else return new Type (this._token, type);
		} else if (auto str = cast (ObjectCstInfo) en.type) {
		    auto type = str.impl.create (this._token, temp.array ());
		    if (this._deco == Keys.REF)
			return new Type (this._token, new RefInfo (type));
		    else return new Type (this._token, type);
		}
	    }
	    throw new UseAsType (this._token);
	} else {
	    auto t_info = InfoType.factory (this._token, temp.array ());
	    if (this._deco == Keys.REF)
		t_info = new RefInfo (t_info);
	    return new Type (this._token, t_info);
	}
    }

    /**
     Returns: 'true' si la variable est un type.
     */
    bool isType () {
	auto info = Table.instance.get (this._token.str);
	if (info is null)
	    return InfoType.exist (this._token.str);
	return false;
    }

    ref Array!Expression templates () {
	return this._templates;
    }
    
    ref Word deco () {
	return this._deco;
    }
    
    override Expression clone () {
	Array!Expression tmps;
	foreach (it; this._templates)
	    tmps.insertBack (it.clone ());
	auto res = new Var (this._token, tmps);
	res.info = this._info;
	res.deco = this._deco;
	return res;
    }
    
    /**
     Affiche la variable sous forme d'arbre
     Params:
     nb = l'offset courant.
     */
    override void print (int nb = 0) {
	writefln ("%s<Var> %s(%d, %d) %s ",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);

	foreach (it ; this._templates) {
	    it.print (nb + 4);
	}
    }

    override string prettyPrint () {
	import std.outbuffer;
	auto buf = new OutBuffer;
	buf.writef ("%s", this._token.str);
	if (!this._templates.empty) {
	    buf.writef ("!(");
	    foreach (it ; this._templates)
		buf.writef ("%s%s", it.prettyPrint, it !is this._templates [$ - 1] ? ", " : ")");
	}
	return buf.toString ();
    }

    
}

/**
 Cette classe est généré à la syntaxe par.
 Example:
 ---
 Identifiant ':' '[' var ']'
 ---
 */
class ArrayVar : Var {

    /// La variable contenu entre les crochet
    private Expression _content;
    
    this (Word token, Expression content) {
	super (token);
	this._content = content;
    }

    /**
     Verification sémantique.
     Pour être juste le contenu doit être un type
     */
    override Var expression () {
	if (auto var = cast (Var) this._content) {
	    auto content = var.asType ();
	    auto tok = Word (this.token.locus, "", false);
	    tok.str = this.token.str ~ this._content.token.str ~ "]";
	    return new Type (tok, new ArrayInfo (content.info.type));
	} else {
	    auto ptr = cast (FuncPtr) this._content.expression ();
	    if (ptr) {
		auto aux = new Type (this._token, new ArrayInfo (ptr.info.type));
		return aux;
	    } else assert (false);
	}
    }

    /++
     alias expression ();
     +/
    override Var var () {
	return this.expression ();
    }
    
    override Var templateExpReplace (Expression [string] values) {
	auto cont = this._content.templateExpReplace (values);
	if (auto vvar = cast (VariadicSoluce) cont) {
	    auto tu = new TupleInfo ();
	    tu.params = make!(Array!InfoType) (vvar.types);
	    cont = new Type (cont.token, tu);
	}
	return new ArrayVar (this._token, 
			     this._content.templateExpReplace (values));
    }
    
    /**
     Verification sémantique.
     Pour être juste le contenu doit être un type
     */    
    override Type asType () {
	return cast (Type) this.expression ();
    }

    ref Expression content () {
	return this._content;
    }

    override Expression clone () {
	return new ArrayVar (this._token, this._content.clone ());
    }
    
    /**
     Returns: 'true'
     */
    override bool isType () {
	return true;
    }    

    override void print (int nb = 0) {
	writefln ("%s<ArrayVar> %s(%d, %d) ",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column,
		  this._token.str);

	this._content.print (nb + 4);
	
    }
    
    override string prettyPrint () {
	import std.format;
	return format ("[%s]", this._content.prettyPrint);
    }    
    
}

/**
 Variable typée, généré à la syntaxe par.
 Example:
 ---
 var ':' var
 ---
 */
class TypedVar : Var {

    /// Le type de la variable (l'element à droite des deux points)
    private Var _type;

    /// Le type de la variable (un pointeur sur fonction).
    private Expression _expType;
    
    this (Word ident, Var type) {
	super (ident);
	this._type = type;
    }

    this (Word ident, Var type, Word deco) {
	super (ident);
	this._type = type;
	this._deco = deco;
    }
    
    this (Word ident, Expression type) {
	super (ident);
	this._expType = type;	
    }

    this (Word ident, Expression type, Word deco) {
	super (ident);
	this._expType = type;
	this._deco = deco;
    }

    
    /**
     Vérification sémantique.
     Pour être juste la variable ne doit pas éxister et l'element de droite doit être un type.    
     */
    override Var expression () {	
	if (this._type) {
	    auto aux = new TypedVar (this._token, this._type.asType ());
	    if (this._deco == Keys.REF) {
		aux.info = new Symbol (this._token, new RefInfo (aux._type.info.type), false);
	    } else
		aux.info = new Symbol (this._token, aux._type.info.type, this._deco == Keys.CONST);
	    Table.instance.insert (aux.info);
	    return aux;
	} else {
	    auto ptr = cast (FuncPtr) this._expType.expression ();
	    if (ptr) {
		auto aux = new TypedVar (this._token, new Type (ptr.token, ptr.info.type));
		if (this._deco == Keys.REF)
		    aux.info = new Symbol (this._token, new RefInfo (aux._type.info.type), false);
		else
		    aux.info = new Symbol (this._token, aux._type.info.type, this._deco == Keys.CONST);
		Table.instance.insert (aux.info);
		return aux;
	    } else assert (false);
	}
    }

    /++ 
     alias expression ();
     +/
    override Var var () {
	return this.expression ();
    }
        
    override Var templateExpReplace (Expression [string] values) {
	if (this._type) {
	    return new TypedVar (this._token, cast (Var) this._type.templateExpReplace (values), this._deco);
	} else
	    return new TypedVar (this._token, this._expType.templateExpReplace (values), this._deco);	
    }
    
    /**
     Returns: le type de la variable
     */
    ref Var type () {
	return this._type;
    }

    override Expression clone () {
	if (this._type)
	    return new TypedVar (this._token, cast (Var) this._type.clone (), this._deco);
	else
	    return new TypedVar (this._token, this._expType.clone (), this._deco);
    }
    
    ref Expression expType () {
	return this._expType;
    }
    
    /**
     Returns: L'information de type de la variable
     */
    InfoType getType () {
	if (type) {
	    auto type = this._type.asType ();
	    if (this._deco == Keys.REF && !cast (RefInfo) type.info.type) {  
		if (cast (EnumInfo) type.info.type)
		    throw new CannotRefEnum (this._deco);
		return new RefInfo (type.info.type);
	    } else return type.info.type;
	} else {
	    this._expType = this._expType.expression ();
	    if (this._deco == Keys.REF && !cast (RefInfo) type.info.type) {
		if (cast (EnumInfo) type.info.type)
		    throw new CannotRefEnum (this._deco);
		return new RefInfo (this._expType.info.type);
	    } else return this._expType.info.type;
	}
    }

    /**
     Affiche l'expression sous forme d'arbre
     */
    override void print (int nb = 0) {
	writef ("%s<TypedVar> %s(%d, %d) %s ",
		rightJustify ("", nb, ' '),
		this._token.locus.file,
		this._token.locus.line,
		this._token.locus.column,
		this._token.str);
	this._type.print ();
	writeln ();
    }

    override string prettyPrint () {
	import std.format;
	if (this._type)
	    return format ("%s : %s", this._token.str, this._type.prettyPrint);
	else return format ("%s : %s", this._token.str, this._expType.prettyPrint);
    }    
}

/**
 Une variable doit on est sur qu'elle est un type.
 */
class Type : Var {
    
    this (Word word, InfoType info) {
	super (word);
	this._info = new Symbol (word, info, true);
    }

    override Type expression () {
	return this.clone ();
    }

    /++
     alias expression ();
     +/
    override Type var () {
	return this.clone ();
    }

    override Var templateExpReplace (Expression [string]) {
	return this.clone ();
    }

    override Type clone () {
	auto ret = new Type (this._token, this._info.type.clone ());
	ret.deco = this._deco;
	return ret;
    }
    
    /**
     Returns: 'this'
     */
    override Type asType () {
	if (this._deco == Keys.REF && !cast(RefInfo) this._info.type)
	    return new Type (this._token, new RefInfo (this._info.type));
	return this;
    }
    
}
