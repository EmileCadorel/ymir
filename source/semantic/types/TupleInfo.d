module semantic.types.TupleInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo;
import semantic.types.UndefInfo, semantic.types.TupleUtils;
import std.container;
import syntax.Tokens;
import semantic.types.StructUtils;
import lint.LSize, semantic.types.ClassUtils;
import semantic.types.StringInfo;

class TupleInfo : InfoType {
    
    /** Les paramètres du tuple */
    private Array!InfoType _params;


    this () {
	this._destruct = &StructUtils.InstDestruct;
    }
    
    /** Returns: les paramètres du tuple */
    ref Array!InfoType params () {
	return this._params;
    }
        
    /**
     Params:
     other = le deuxieme type
     Returns: les deux types sont identique ?
     */
    override bool isSame (InfoType other) {
	if (auto tu = cast (TupleInfo) other) {
	    if (tu._params.length != this._params.length) return false;
	    foreach (it ; 0 .. this._params.length) {
		if (!tu._params [it].isSame (this._params [it]))
		    return false;
	    }
	    return true;
	}
	return false;
    }


    /**
     Cree un type typle en fonction de paramètre template.
     Params:
     token = l'identifiant du créateur.
     templates = les attributs templates.
     Returns: une instance de tuple
     Throws: UndefinedType
    */
    static InfoType create (Word token, Expression [] templates) {
	if (templates.length < 2)
	    throw new UndefinedType (token, "prend au moins deux type en template");
	auto tuple = new TupleInfo ();
	foreach (it ; 0 .. templates.length) {
	    tuple._params.insertBack (templates [it].info.type);
	}
	return tuple;
    }

    /**
     Surcharge des operateurs binaires à droite.
     Params:
     op = l'operateur.
     left = l'operande gauche de l'expression.
     Returns: le type résultat ou null.
     */
    override InfoType BinaryOpRight (Word op, Expression left) {
	if (op == Tokens.EQUAL) return AffectRight (left);
	return null;
    }

    /**
     Operateur '=' à droite.
     Params:
     left = l'operande gauche de l'expression
     Returns: le type résultat ou null.
     */    
    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto ret = new TupleInfo ();
	    foreach (it ; this._params) {
		ret._params.insertBack (it.clone ());
	    }
	    ret.lintInst = &TupleUtils.InstAffectRight;
	    return ret;
	}
	return null;
    }

    override InfoType CompOp (InfoType other) {
	if (other.isSame (this) || cast (UndefInfo) other) {
	    auto tu = this.clone ();
	    tu.lintInst = &TupleUtils.InstAffectRight;
	    return tu;
	}
	return null;
    }
    
    override string typeString () {
	auto name = "(";
	foreach (it ; this._params) {
	    if (auto _st = cast (TupleInfo) it)
		name ~= "tuple(...)";
	    else name ~= it.typeString ();
	    if (it !is this._params [$ - 1]) name ~= ", ";	    
	}
	name ~= ")";
	return name;
    }
    
    override string simpleTypeString () {
	auto name = "t";
	foreach (it ; this._params) {
	    name ~= it.simpleTypeString ();
	}
	return name;
    }
    
    override InfoType clone () {
	auto tu = new TupleInfo ();
	foreach (it; this._params) {
	    tu._params .insertBack (it.clone ());
	}
	if (this._destruct is null) tu.setDestruct (null);
	return tu;
    }

    override InfoType cloneForParam () {
	auto tu = new TupleInfo ();
	foreach (it; this._params) {
	    tu._params.insertBack (it.clone ());
	}
	return tu;
    }

    override InfoType ParamOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstParam);
	return ret;
    }

    override InfoType ReturnOp () {
	auto ret = this.clone ();
	ret.lintInstS.insertBack (&ClassUtils.InstReturn);
	return ret;
    }    

    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") return StringOf ();
	return null;
    }
   
    /**
     Le nom du type tuple ("tupleExp".typeid).
     Returns: un type string.
     */
    private InfoType StringOf () {
	auto str = new StringInfo ();
	str.lintInst = &TupleUtils.TupleStringOf;
	str.leftTreatment = &TupleUtils.TupleGetStringOf;
	return str;
    }

    
    override InfoType destruct () {
	if (this._destruct is null) return null;
	auto ret = this.clone ();
	ret.setDestruct (this._destruct);
	return ret;
    }

    override LSize size () {
	return LSize.LONG;
    }
        
}
    
