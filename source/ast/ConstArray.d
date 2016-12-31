module ast.ConstArray;
import ast.Expression;
import std.container;
import semantic.types.InfoType;
import semantic.pack.Symbol;
import semantic.types.ArrayInfo;
import syntax.Word;
import semantic.types.VoidInfo, semantic.types.UndefInfo;
import ast.Var;
import utils.exception;
import std.stdio, std.string;


/**
 Classe généré par la syntaxe.
 Example:
 ---
 '[' expression * ']'
 ---
 */
class ConstArray : Expression  {

    /// Les paramètres de l'expression
    private Array!Expression _params;

    /// Les casters de l'expression (généré à la sémantique)
    private Array!InfoType _casters;
    
    this (Word token, Array!Expression params) {
	super (token);
	this._params = params;
    }

    /**
     Returns: Les paramètres de l'expression
     */
    Array!Expression params () {
	return this._params;
    }
    
    /**
     Returns: Les casters de l'expression
     */
    Array!InfoType casters () {
	return this._casters;
    }

    /**
     Vérification sémantique
     Pour être juste l'expression ne doit contenir que des expressions de types compatible.
     Ou, un seul type.
     Throws: IncompatibleTypes, UseAsVar.
     */
    override Expression expression () {
	auto aux = new ConstArray (this._token, this._params);
	if (aux._params.length == 0) {
	    aux.info = new Symbol (aux._token, new ArrayInfo (new VoidInfo), true);
	} else {
	    InfoType last = null;
	    foreach (ref it ; aux._params) {
		it = it.expression;
	    }

	    if (aux._params.length == 1) {
		auto type = cast (Type) aux._params [0];
		if (type) {
		    auto tok = Word (this.token.locus,
				     this.token.str,
				     false);
		    tok.str = this.token.str ~ type.token.str ~ "]";
		    return new Type (tok, new ArrayInfo (type.info.type));
		}
	    }
	    
	    auto begin = new Symbol(false, this._token, new UndefInfo ());	    
	    foreach (fst ; 0 .. aux._params.length) {
		if (cast (Type) aux._params [fst]) throw new UseAsVar (aux._params [fst].token, aux._params [fst].info);
		auto cmp = aux._params [fst].info.type.CompOp (begin.type);
		aux._casters.insertBack (cmp);
		if (cmp is null) {
		    throw new IncompatibleTypes (begin,
						 aux._params [fst].info);
		}
		begin.type = cmp;
	    }
	    aux._info = new Symbol (aux._token, new ArrayInfo (begin.type.clone ()), true);
	}
	return aux;
    }

    /**
     Affiche l'expression sous forme d'arbre.
     Params:
     nb = l'offset courant
     */
    override void print (int nb = 0) {
	writefln ("%s<Array> %s(%d, %d) ",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);
	foreach (it ; this._params) {
	    it.print (nb + 4);
	}
    }
    

}
