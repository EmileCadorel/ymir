module ast.ConstRange;
import ast.Expression;
import std.container;
import semantic.types.InfoType;
import semantic.pack.Symbol;
import syntax.Word;
import ast.Var;
import semantic.types.FloatInfo;
import semantic.types.CharInfo;
import utils.exception;
import std.stdio, std.string;
import semantic.types.RangeInfo;
import semantic.types.DecimalInfo;


/**
 Classe généré à la syntaxe par.
 Example:
 ---
 expression '..' expression
 ---
 */
class ConstRange : Expression {

    /// l'élément de gauche
    private Expression _left;

    /// l'élément de droite
    private Expression _right;

    /// le type de l'expression
    private InfoType _content;

    private ubyte _lorr = 0;

    private InfoType _caster = null;
    
    this (Word token, Expression left, Expression right) {
	super (token);
	this._left = left;
	this._right = right;
	this._left.inside = this;
	this._left.inside = this;
    }

    /**
     Returns: l'élément de gauche
     */
    Expression left () {
	return this._left;
    }

    /**
     Returns: l'élément de droite
     */
    Expression right () {
	return this._right;
    }    

    ubyte lorr () {
	return this._lorr;
    }

    /**
     Returns: l'information type du contenu
     */
    InfoType content () {
	return this._content;
    }

    InfoType caster () {
	return this._caster;
    }
    
    /**
     Vérification sémantique.
     Pour être correct, gauche et droite doivent être compatible et de type que l'on peut mettre dans un Range.
     Throws: UndefinedOp
    */
    override Expression expression () {
	auto aux = new ConstRange (this._token, this._left.expression, this._right.expression);
	auto type = aux._left.info.type.CompOp (aux._right.info.type);
	if (!cast (FloatInfo) type && !cast (DecimalInfo) type && !cast (CharInfo) type) {
	    auto call = findOpRange (aux);
	    if (!call)
		throw new UndefinedOp (this._token, aux._left.info, aux._right.info);
	    else {
		//call.garbage ();
		return call;
	    }
	}
	
	if (!type.isSame (aux._left.info.type)) {
	    aux._lorr = 1;
	    aux._caster = aux._left.info.type.CastTo (type);
	} else if (!type.isSame (aux._right.info.type)) {
	    aux._lorr = 2;
	    aux._caster = aux._right.info.type.CastTo (type);
	}
	
	aux._content = type;
	aux._info = new Symbol (aux._token, new RangeInfo (type), true);
	if (aux._left.info.isImmutable && aux._right.info.isImmutable) {
	    import semantic.value.RangeValue;
	    aux.info.value = new RangeValue (aux._left.info.value, aux._right.info.value);
	}
	return aux;
    }

    auto findOpRange (ConstRange aux) {
	import ast.Par, syntax.Keys, ast.ParamList;
	try {
	    auto word = Word (this._token.locus, Keys.OPRANGE.descr, true);
	    auto var = new Var (word);
	    auto params = new ParamList (this._token,
					 make!(Array!Expression) (this._left, this._right));
	    auto call = new Par (this._token, this._token, var, params);
	    return call.expression;	    
	} catch (YmirException tm) {
	    return null;
	}
    }
            
    override Expression templateExpReplace (Expression [string] values) {
	auto left = this._left.templateExpReplace (values);
	auto right = this._right.templateExpReplace (values);
	return new ConstRange (this._token, left, right);
    }

    override Expression clone () {
	return new ConstRange (this._token, this._left.clone, this._right.clone ());
    }

    override string prettyPrint () {
	import std.format;
	return format ("%s .. %s", this._left.prettyPrint, this._right.prettyPrint);
    }
    

}
