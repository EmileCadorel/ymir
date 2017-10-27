module ymir.semantic.types.TupleInfo;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;

class TupleInfo : InfoType {
    
    /** Les paramètres du tuple */
    private Array!InfoType _params;    

    this (bool isConst) {
	super (isConst);
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
	auto tuple = new TupleInfo (false);
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
	    auto ret = new TupleInfo (false);
	    foreach (it ; this._params) {
		ret._params.insertBack (it.clone ());
		ret._params.back ().value = null;
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

    override InfoType CastOp (InfoType other) {
	if (auto arr = cast (ArrayInfo) other) {
	    if (this._params.length == 2) {
		auto ul = cast (DecimalInfo) this._params [0];
		auto pt = cast (PtrInfo) this._params [1];
		if (ul && pt && ul.type == DecimalConst.ULONG) {
		    auto ret = other.clone ();
		    ret.lintInst = &TupleUtils.InstAffectRight;
		    return ret;
		}		
	    }
	}
	return null;
    }
    
    override InfoType DotExpOp (Expression right) {
	if (auto dec = cast (DecimalValue) right.info.value) {
	    auto attr = dec.get!(ulong);
	    if (attr < this._params.length) {
		auto type = this._params [attr].clone ();
		type.toGet = attr;
		type.lintInst = &TupleUtils.Attrib;
		type.leftTreatment = &TupleUtils.GetAttrib;
		type.isConst = this.isConst;
		return type;
	    }
	    return null;
	} else return null;
    }
    
    override string innerTypeString () {
	auto name = "tuple(";
	if (this._isType) name = "tuple!(";
	foreach (it ; this._params) {
	    if (auto _st = cast (TupleInfo) it) {
		name ~= "tuple(...)";
	    } else name ~= it.innerTypeString ();
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
	auto tu = new TupleInfo (this.isConst);
	foreach (it; this._params) {
	    tu._params .insertBack (it.clone ());
	}
	tu.value = this._value;
	tu._isType = this._isType;
	return tu;
    }

    override Expression toYmir () {
	Array!Expression params;
	foreach (it ; this._params) {
	    params.insertBack (it.toYmir ());
	}
	Word w = Word.eof;
	w.str = "t";
	auto ret = new Var (w, params);
	ret.info = new Symbol (w, this.clone ());
	return ret;
    }
    
    override InfoType cloneForParam () {
	auto tu = new TupleInfo (this.isConst);
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
	auto str = new StringInfo (true);
	str.value = new StringValue (this.typeString);
	return str;
    }

    private InfoType Ptr () {
	auto ret = new PtrInfo (this.isConst, new VoidInfo);
	ret.lintInst = &StructUtils.InstPtr;
	return ret;
    }

    
    private InfoType SizeOf () {
	auto ret = new DecimalInfo (true, DecimalConst.UBYTE);
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

       
    override LSize size () {
	return LSize.LONG;
    }
        
    override InfoType getTemplate (ulong i) {
	if (i < this._params.length)
	    return this._params [i];
	return null;
    }

    override InfoType [] getTemplate (ulong bef, ulong af) {
	if (bef < this._params.length) {
	    InfoType [] ret = new InfoType [this._params.length - bef - af];
	    foreach (it ; bef .. this._params.length - af) {
		ret [it - bef] = this._params [it];
	    }
	    return ret;
	}
	return null;
    }
    
}
    
