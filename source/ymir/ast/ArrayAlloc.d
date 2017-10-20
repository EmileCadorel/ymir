module ymir.ast.ArrayAlloc;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;


import std.container;
import std.stdio, std.string;

/**
 Classe généré par la syntaxe.
 Example:
 ----
 '[' type ';' expression ']';
 ----
*/
class ArrayAlloc : Expression {

    /** Le type de l'allocation */
    private Expression _type;

    /** La taille de l'allocation */
    private Expression _size;

    /** Le caster vers ulong */
    private InfoType _cster;
    
    this (Word token, Expression type, Expression size) {
	super (token);
	this._type = type;
	this._size = size;
	this._size.inside = this;
	if (this._type)
	    this._type.inside = this;
    }


    /**
     Vérification sémantique.
     Pour être juste l'expression doit contenir un type valable et une expression décimale de taille entiere.
     Throws: UseAsType, IncompatibleTypes
     */
    override Expression expression () {
	auto aux = new ArrayAlloc (this._token, null, this._size.expression);

	if (auto fn = cast (FuncPtr) this._type) aux._type = fn.expression ();
	else if (auto type = cast (Var) this._type)  aux._type = type.asType ();
	else throw new UseAsType (this._type.token);
	
	if (auto type = cast (StructCstInfo) aux._type.info.type) {
	    aux._type.info.type = type.CallOp (aux._type.token, new ParamList (this._token, make!(Array!Expression))).ret;
	} 
		
	auto ul = new Symbol (this._token, new DecimalInfo (true, DecimalConst.ULONG));
	auto cmp = aux._size.info.type.CompOp (ul.type);
	if (cmp is null) throw new IncompatibleTypes (ul, aux._size.info);
	aux._cster = cmp;
	
	aux.info = new Symbol (this._token, new ArrayInfo (false, aux._type.info.type.clone));
	return aux;	
    }

    override Expression templateExpReplace (Expression [string] values) {
	auto type = this._type.templateExpReplace (values);
	auto size = this._size.templateExpReplace (values);
	return new ArrayAlloc (this._token, type, size);
    }

    override Expression clone () {
	return new ArrayAlloc (this._token, this._type.clone, this._size.clone ());
    }
    
    override void print (int nb = 0) {
	writefln ("%s<ArrayAlloc> %s(%d, %d) ",
		  rightJustify ("", nb, ' '),
		  this._token.locus.file,
		  this._token.locus.line,
		  this._token.locus.column);

	this._type.print (nb + 4);
	this._size.print (nb + 4);
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
    
    override string prettyPrint () {
	import std.format;
	return format ("[%s; %s]", this._type.prettyPrint (), this._size.prettyPrint ());
    }

    
}

