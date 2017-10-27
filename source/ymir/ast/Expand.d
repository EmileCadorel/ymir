module ymir.ast.Expand;
import ymir.utils._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.ast._;

import std.container, std.stdio;


/**
 Classe généré par la syntaxe
 Example:
 ---
 'expand' '(' exp ')'
 ----
 */
class Expand : Expression {

    /** Le paramètre de l'expand */
    private Expression _expr;

    /** Le debut de l'expand */
    private ulong _index;

    private ulong _id;

    private static ulong __lastId__ = 0;
    
    this (Word begin, Expression expr, ulong id = 0) {
	super (begin);
	this._expr = expr;
	this._expr.inside = this;
	if (id == 0) {
	    this._id = __lastId__ + 1;
	    __lastId__ ++;
	} else this._id = id;
    }

    this (Word begin, Expression expr, ulong index, ulong id = 0) {
	super (begin);
	this._expr = expr;
	this._expr.inside = this;
	this._index = index;
	if (id == 0) {
	    this._id = __lastId__ + 1;
	    __lastId__ ++;
	} else this._id = id;
    }
    
    /**
     Vérification sémantique.
     Pour être juste le contenu doit surcharger doit être de type tuple.
     Throws: UseAsVar, si le contenu est un type
     */
    override Expression expression () {
	if (this._expr.info) return this;
	auto expr = this._expr.expression ();
	if (cast (Type) expr || expr.info.isType) throw new UseAsVar (expr.token, expr.info);
	auto tuple = cast (TupleInfo) expr.info.type;
	auto str = cast (StructInfo) expr.info.type;
	if (!tuple) return expr;
	Array!Expression params;	
	
	if (tuple) {
	    foreach (it ; 0 .. tuple.params.length) {
		auto exp = new Expand (this._token, expr, it, this._id);
		exp.info = new Symbol (exp.token, tuple.params[it].clone);
		exp.info.isConst = tuple.isConst;
		params.insertBack (exp);
	    }
	}

	auto aux = new ParamList (this._token, params);	
	aux.info = new Symbol (this._token, new UndefInfo ());
	return aux;
    }

    override Expression templateExpReplace (Expression [string] values) {
	auto expr = this._expr.templateExpReplace (values);
	return new Expand (this._token, expr);
    }

    override protected Expression onClone () {
	return new Expand (this._token, this._expr.clone ());
    }
    
    /**
     Returns: le contenu étendue.
     */
    Expression expr () {
	return this._expr;
    }    

    ulong index () {
	return this._index;
    }

    ulong id () {
	return this._id;
    }

    static ulong lastId () {
	__lastId__ ++;
	return __lastId__ - 1;
    }
    
    override string prettyPrint () {
	import std.format;
	if (this._index == 0)
	    return format ("expand (%s)", this._expr.prettyPrint);
	else return format ("expand (%s : %d)", this._expr.prettyPrint, this._index);
    }    
    
}
