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
import ast.ParamList;

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
	if (this._isType) return null;
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
	if (this._isType) return null;
	if (other.isSame (this) || cast (UndefInfo) other) {
	    auto tu = this.clone ();
	    tu.lintInst = &TupleUtils.InstAffectRight;
	    return tu;
	}
	return null;
    }
    
    override InfoType DotExpOp (Expression right) {
	import semantic.value.DecimalValue;
	if (auto dec = cast (DecimalValue) right.info.value) {
	    auto attr = dec.get!(ulong);
	    if (attr < this._params.length) {
		auto type = this._params [attr].clone ();
		type.toGet = attr;
		type.lintInst = &TupleUtils.Attrib;
		type.leftTreatment = &TupleUtils.GetAttrib;
		type.isConst = false;
		type.isGarbaged = false;
		return type;
	    }
	    return null;
	} else return null;
    }
    
    override string typeString () {
	auto name = "tuple(";
	if (this._isType) name = "tuple!(";
	foreach (it ; this._params) {
	    if (auto _st = cast (TupleInfo) it) {
		name ~= "tuple(...)";
	    } else name ~= it.typeString ();
	    if (it !is this._params [$ - 1]) name ~= ", ";	    
	}
	name ~= ")";
	return name;
    }
    
    override string simpleTypeString () {
	auto name = "T";
	foreach (it ; this._params) {
	    name ~= it.simpleTypeString ();
	}
	return name ~ "";
    }
    
    override TupleInfo clone () {
	auto tu = new TupleInfo ();
	foreach (it; this._params) {
	    tu._params .insertBack (it.clone ());
	}
	if (this._destruct is null) tu.setDestruct (null);
	tu.value = this._value;
	tu._isType = this._isType;
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
	if (var.templates.length != 0) return null;
	if (var.token.str == "typeid") return StringOf ();
	else if (var.token.str == "sizeof") return SizeOf ();
	else if (var.token.str == "ptr") return Ptr ();
	else if (var.token.str == "empty") return Empty ();
	return null;
    }
   
    /**
     Le nom du type tuple ("tupleExp".typeid).
     Returns: un type string.
     */
    private InfoType StringOf () {
	auto str = new StringInfo ();
	str.value = new StringValue (this.typeString);
	return str;
    }

    private InfoType Ptr () {
	import semantic.types.PtrInfo, semantic.types.VoidInfo;
	auto ret = new PtrInfo (new VoidInfo);
	ret.lintInst = &StructUtils.InstPtr;
	return ret;
    }

    
    private InfoType SizeOf () {
	import semantic.types.DecimalInfo, ast.Constante;
	auto ret = new DecimalInfo (DecimalConst.UBYTE);
	ret.lintInst = &TupleUtils.SizeOf;
	ret.leftTreatment = &TupleUtils.GetSizeOf;
	return ret;
    }

    private InfoType Empty () {
	auto ret = this.clone ();
	ret._isType = false;
	ret.lintInst = &TupleUtils.InstCallEmpty;
	ret.leftTreatment = &TupleUtils.InstCreateCstEmpty;
	return ret;
    }
    
    override InfoType destruct () {
	if (this._destruct is null || this._isType) return null;
	auto ret = this.clone ();
	ret.setDestruct (this._destruct);
	return ret;
    }


    override LSize size () {
	return LSize.LONG;
    }
        
    override InfoType getTemplate (ulong i) {
	if (i < this._params.length)
	    return this._params [i];
	return null;
    }

}
    
