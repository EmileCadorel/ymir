module ast.ParamList;
import ast.Expression, utils.exception;
import semantic.types.UndefInfo;
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
	foreach (it ; this._params) {
	    aux._params.insertBack (it.expression ());
	    if (cast (UndefInfo) aux._params.back ().info.type)
		throw new UninitVar (aux._params.back.token);
	}
	return aux;
    }

    /**
     Returns: La liste des paramètres
     */
    Array!Expression params () {
	return this._params;
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
