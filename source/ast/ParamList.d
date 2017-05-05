module ast.ParamList;
import ast.Expression, utils.exception;
import semantic.types.UndefInfo;
import semantic.types.InfoType;
import std.container, syntax.Word;
import std.stdio, std.string;
import ast.Var;

/**
 Une liste de paramètre peut être généré à la syntaxe dans deux cas.
 Example:
 ---
 expression '[' expression ','* ']'
 // ou
 expression '(' expression ','* ')'
 ---
 */
class ParamList : Expression {

    private Array!Expression _params; /// Les paramètres de l'expression
    
    this (Word word, Array!Expression params) {
	super (word);
	this._params = params;
    }

    this (Word word) {
	super (word);
    }

    /**
     Vérification sémantique.
     Pour être juste, tous les paramètre doivent être juste.
     Throws: UninitVar, si un des éléments est de type indéfinis.
     */
    override Expression expression () {
	auto aux = new ParamList (this._token);
	foreach (it ; 0 .. this._params.length) {
	    Expression ex_it = this._params [it].expression;
	    if (auto ex = cast (ParamList) ex_it) {
		foreach (_it ; ex.params) {
		    aux._params.insertBack (_it);
		    if (cast (UndefInfo) aux._params.back ().info.type)
			throw new UninitVar (aux._params.back.token);
		}
	    } else {
		aux._params.insertBack (ex_it);
		if (cast (UndefInfo) aux._params.back ().info.type)
		    throw new UninitVar (aux._params.back.token);
		else if (cast (Type) aux._params.back ())
		    throw new UseAsVar (aux._params.back().token, aux._params.back ().info);
		else if (aux._params.back ().info.isType)
		    throw new UseAsVar (aux._params.back().token, aux._params.back ().info);		
	    }
	}
	return aux;
    }

    override void removeGarbage () {
	super.removeGarbage ();
	foreach (it; this._params)
	    it.removeGarbage ();
    }

    override void garbage () {
	super.garbage ();
	foreach (it; this._params)
	    it.garbage ();
    }
    
    override ParamList templateExpReplace (Array!Expression names, Array!Expression values) {
	Array!Expression params;
	foreach (it ; this._params)
	    params.insertBack(it.templateExpReplace (names, values));
	
	return new ParamList (this._token, params);
    }

    override Expression clone () {
	Array!Expression params;
	params.length = this._params.length;
	foreach (it ; 0 .. params.length)
	    params [it] = this._params [it].clone ();
	return new ParamList (this._token, params);
    }
    
    
    /**
     Returns: La liste des paramètres
     */
    ref Array!Expression params () {
	return this._params;
    }
    
    /**
     Returns: la taille de la liste de parametre
     */
    ulong length () {
	return this._params.length;
    }
    
    
    Array!InfoType paramTypes () {
	Array!InfoType types;
	foreach (it ; this._params) {
	    types.insertBack (it.info.type);
	}
	return types;
    }

    
    /**
     Affiche l'expression sous forme d'arbre
     Params:
     nb = L'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<ParamList> %s(%d, %d)",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}
    }
    

    override string prettyPrint () {
	import std.outbuffer;
	auto buf = new OutBuffer;
	buf.writef ("(");
	foreach (it ; this._params)
	    buf.writef ("%s%s", it.prettyPrint, it !is this._params [$ - 1] ? ", " : ")");
	return buf.toString;
    }

}
