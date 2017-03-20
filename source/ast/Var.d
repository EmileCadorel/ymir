module ast.Var;
import ast.Expression, semantic.pack.Table;
import syntax.Word, std.container, semantic.types.InfoType;
import std.stdio, std.string, std.outbuffer, utils.YmirException;
import semantic.pack.Symbol;
import utils.exception;
import semantic.types.ArrayInfo;
import ast.FuncPtr;


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

    this (Word ident) {
	super (ident);
    }
    
    this (Word ident, Array!Expression templates) {
	super (ident);
	this._templates = templates;
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
     Pour être juste le symbole de l'identifiant doit éxister.
     Il peut être un type, une fonction, une structure ...
     Throws: UndefinedVar, si l'identifiant n'existe pas
     */
    override Var expression () {
	if (!isType) {
	    auto aux = new Var (this._token);	    
	    aux.info = Table.instance.get (this._token.str);
	    if (aux.info is null) 
		throw new UndefinedVar (this._token);
	    
	    if (this._templates.length != 0) {
		Table.instance.pacifyMode ();
		auto id = aux.info.id;
		Array!Expression tmps;
		foreach (it ; this._templates) {
		    tmps.insertBack (it.expression ());
		}
		Table.instance.unpacifyMode ();
		
		auto type = aux.info.type.TempOp (tmps);
		if (type is null)
		    throw new NotATemplate (this._token);
		
		aux.templates = tmps;
		aux.info = new Symbol (aux.info.isGarbage, aux.info.sym, type, true);
	    }	    
	    return aux;	
	} else return asType ();
    }

    override Expression templateExpReplace (Array!Var names, Array!Expression values) {
	foreach (it ; 0 .. values.length) {
	    if (names [it].token.str == this._token.str) {
		auto clo = values [it].clone ();
		clo.token = this._token;
		return clo;
	    }
	}

	Array!Expression tmps;
	foreach (it ; this._templates)
	    tmps.insertBack (it.templateExpReplace (names, values));

	return new Var (this._token, tmps);
    }
    
    /**
     Met à jour le type de la variable
     Params:
     info = le symbole du type à affecter à la variable
     */
    TypedVar setType (Symbol info) {
	auto type = new Type (info.sym, info.type.cloneForParam ());
	return new TypedVar (this._token, type);
    }

    /**
     Met à jour le type de la variable
     Params:
     info = l'information du type à affecter à la variable
     */
    TypedVar setType (InfoType info) {
	auto type = new Type (this._token, info.cloneForParam ());
	return new TypedVar (this._token, type);
    }    

    /**
     Vérification sémantique.
     Pour être juste la variable doit être un type.
     Throws: UseAsType, si le type n'existe pas.
     */
    Type asType () {	
	if (!InfoType.exist (this._token.str)) throw new UseAsType (this._token);
	else {
	    import std.array;
	    Array!Expression temp;
	    foreach (it ; this._templates) {
		temp.insertBack (it.expression);
	    }
	    auto t_info = InfoType.factory (this._token, temp.array ());
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

    override Expression clone () {
	Array!Expression tmps;
	foreach (it; this._templates)
	    tmps.insertBack (it.clone ());
	return new Var (this._token, tmps);
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
    private Var _content;
    
    this (Word token, Var content) {
	super (token);
	this._content = content;
    }

    /**
     Verification sémantique.
     Pour être juste le contenu doit être un type
     */
    override Var expression () {
	auto content = this._content.asType ();
	auto tok = Word (this.token.locus, "", false);
	tok.str = this.token.str ~ this._content.token.str ~ "]";
	return new Type (tok, new ArrayInfo (content.info.type));
    }

    override Var templateExpReplace (Array!Var names, Array!Expression values) {
	auto cont = this._content.templateExpReplace (names, values);
	return new ArrayVar (this._token, cast (Var) this._content.templateExpReplace (names, values));
    }
    
    /**
     Verification sémantique.
     Pour être juste le contenu doit être un type
     */    
    override Type asType () {
	auto content = this._content.asType ();
	auto tok = Word (this.token.locus, "", false);
	tok.str = this.token.str ~ this._content.token.str ~ "]";
	return new Type (tok, new ArrayInfo (content.info.type));
    }

    ref Var content () {
	return this._content;
    }

    override Expression clone () {
	return new ArrayVar (this._token, cast (Var) this._content.clone ());
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

    this (Word ident, Expression type) {
	super (ident);
	this._expType = type;	
    }

    /**
     Vérification sémantique.
     Pour être juste la variable ne doit pas éxister et l'element de droite doit être un type.    
     */
    override Var expression () {
	if (this._type) {
	    auto aux = new TypedVar (this._token, this._type.asType ());
	    aux.info = new Symbol (this._token, aux._type.info.type, false);
	    Table.instance.insert (aux.info);
	    return aux;
	} else {
	    auto ptr = cast (FuncPtr) this._expType.expression ();
	    if (ptr) {
		auto aux = new TypedVar (this._token, new Type (ptr.token, ptr.info.type));
		aux.info = new Symbol (this._token, aux._type.info.type, false);
		Table.instance.insert (aux.info);
		return aux;
	    } else assert (false);
	}
    }

    override Var templateExpReplace (Array!Var names, Array!Expression values) {
	if (this._type)
	    return new TypedVar (this._token, cast (Var) this._type.templateExpReplace (names, values));
	else
	    return new TypedVar (this._token, this._expType.templateExpReplace (names, values));	
    }
    
    /**
     Returns: le type de la variable
     */
    ref Var type () {
	return this._type;
    }

    override Expression clone () {
	if (this._type)
	    return new TypedVar (this._token, cast (Var) this._type.clone ());
	else
	    return new TypedVar (this._token, this._expType.clone ());
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
	    return type.info.type;
	} else {
	    if (this._expType.info is null)
		this._expType = this._expType.expression ();
	    return this._expType.info.type;
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

}

/**
 Une variable doit on est sur qu'elle est un type.
 */
class Type : Var {
    
    this (Word word, InfoType info) {
	super (word);
	this._info = new Symbol (false, word, info, true);
    }

    override Type expression () {
	return this.clone ();
    }

    override Var templateExpReplace (Array!Var, Array!Expression) {
	return this.clone ();
    }

    override Type clone () {
	return new Type (this._token, this._info.type.clone ());
    }
    
    /**
     Returns: 'this'
     */
    override Type asType () {
	return this;
    }

}
