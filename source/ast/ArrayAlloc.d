module ast.ArrayAlloc;
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
import semantic.types.DecimalInfo;
import ast.Constante;

/**
 Classe généré par la syntaxe.
 Example:
 ----
 '[' type ';' expression ']';
 ----
*/
class ArrayAlloc : Expression {

    /** Le type de l'allocation */
    private Var _type;

    /** La taille de l'allocation */
    private Expression _size;

    /** Le caster vers ulong */
    private InfoType _cster;
    
    this (Word token, Var type, Expression size) {
	super (token);
	this._type = type;
	this._size = size;
    }


    /**
     Vérification sémantique.
     Pour être juste l'expression doit contenir un type valable et une expression décimale de taille entiere.
     Throws: UseAsType, IncompatibleTypes
     */
    override Expression expression () {
	auto aux = new ArrayAlloc (this._token, this._type.expression, this._size.expression);


	auto ul = new Symbol (false, this._token, new DecimalInfo (DecimalConst.ULONG));
	auto cmp = aux._size.info.type.CompOp (ul.type);
	if (cmp is null) throw new IncompatibleTypes (ul, aux._size.info);
	if ((cast(Type) aux._type) is null) throw new UseAsType (aux._type.token);	
	aux._cster = cmp;
	aux.info = new Symbol (this._token, new ArrayInfo (aux._type.info.type.clone));
	
	return aux;	
    }

    /**
     Returns: le caster en ulong.
     */
    InfoType cster () {
	return this._cster;
    }

    /**
     Returns: la taille du tableau
     */
    Expression size () {
	return this._size;
    }

    /**
     Returns: le type du contenu du tableau
     */
    Expression type () {
	return this._type;
    }
    

}

