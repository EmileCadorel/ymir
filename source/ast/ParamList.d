module ast.ParamList;
import ast.Expression, utils.exception;
import semantic.types.UndefInfo;
import semantic.types.InfoType;
import std.container, syntax.Word;
import std.stdio, std.string;

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
	    }
	}
	return aux;
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
    
}
