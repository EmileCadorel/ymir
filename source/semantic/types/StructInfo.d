module semantic.types.StructInfo;
import semantic.types.InfoType;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.StructUtils, syntax.Keys;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;
import semantic.types.PtrInfo, std.stdio;
import std.container, semantic.types.FunctionInfo, std.outbuffer;
import ast.ParamList, semantic.pack.Frame, semantic.types.StringInfo;
import semantic.pack.Table, utils.exception, semantic.types.ClassUtils;
import semantic.types.BoolUtils, semantic.types.RefInfo;

/**
 Le constructeur de structure
*/
class StructCstInfo : InfoType {

    private string _name;
    private Array!TypedVar _params;
    private Array!InfoType _types;
    private Array!string _names;
    
    this (string name) {
	this._name = name;
    }

    void addAttrib (TypedVar type) {
	this._params.insertBack (type);
    }

    string name () {
	return this._name;
    }
    
    static InfoType create (Word name, Expression [] templates) {
	auto cst = cast(StructCstInfo) (Table.instance.get (name.str).type);
	if (cst is null) assert (false, "Nooooon !!!");
	if (templates.length != 0) throw new NotATemplate (name);
	if (cst._types.empty) {
	    foreach (it ; cst._params) {
		auto printed = false;
		auto sym = Table.instance.get (it.type.token.str);
		if (sym) {
		    auto _st = cast (StructCstInfo) (sym.type);
		    if (_st) {
			cst._types.insertBack (_st);
			cst._names.insertBack (it.token.str);
			printed = true;
		    }
		}
		if (!printed) {
		    cst._types.insertBack (it.getType ());
		    cst._names.insertBack (it.token.str);
		}
	    }
	}
	
	return StructInfo.create (cst._name, cst._names, cst._types);
    }
    
    override bool isSame (InfoType) {
	return false;
    }
    
    override InfoType clone () {
	return this;
    }

    override InfoType cloneForParam () {
	assert (false, "constructeur de structure en param !?!");
    }

    override ApplicationScore CallOp (Word token, ParamList params) {
	if (params.params.length != this._params.length) {
	    return null;
	}

	Array!InfoType types;
	Array!string names;
	auto score = new ApplicationScore (token);
	foreach (it ; 0 .. this._params.length) {
	    auto info = this._params [it].getType ();
	    types.insertBack (info);
	    names.insertBack (this._params [it].token.str);
	    auto type = params.params [it].info.type.CompOp (info);
	    if (info.isSame (type)) {
		score.score += Frame.SAME;
		score.treat.insertBack (type);
	    } else if (type !is null) {
		score.score += Frame.AFF;
		score.treat.insertBack (type);
	    } else return null;
	}
	
	auto ret = StructInfo.create (this._name, names, types);
	ret.lintInstMult = &StructUtils.InstCall;
	ret.leftTreatment = &StructUtils.InstCreateCst;
	score.dyn = true;
	score.ret = ret;
	return score;
    }

    
    override string typeString () {
	auto name = this._name ~ "(";
	if (this._types.empty) {	    
	    foreach (it ; this._params) {
		if (auto _st = cast(StructCstInfo) it.getType ())
		    name ~= _st.name ~ "(...)";
		else if (auto _st = cast (StructInfo) it.getType ())
		name ~= _st.name ~ "(...)";
		else
		    name ~= it.getType ().typeString ();
		if (it !is this._params [$ - 1]) name ~= ", ";
	    }
	} else {
	    foreach (it ; this._types) {
		if (auto _st = cast(StructCstInfo) it)
		    name ~= _st.name ~ "(...)";
		else if (auto _st = cast (StructInfo) it)
		    name ~= _st.name ~ "(...)";
		else
		    name ~= it.typeString ();
		if (it !is this._types [$ - 1]) name ~= ", ";
	    }
	}
	name ~= ")";
	return name;
    }

    override LSize size () {
	return LSize.LONG;
    }

    override void quit (string) {
	InfoType.removeCreator (this._name);
    }
    
    
}

class StructInfo : InfoType {

    private Array!InfoType _params;
    private Array!string _attribs;
    private string _name;
    
    private this (string name, Array!string names, Array!InfoType params) {
	this._name = name;
	this._attribs = names;
	this._params = params;
	this._destruct = &StructUtils.InstDestruct;
    }    
    
    static InfoType create (string name, Array!string names, Array!InfoType params) {
	return new StructInfo (name, names, params);
    }


    Array!InfoType params () {
	return this._params;
    }

    
    string name () {
	return this._name;
    }    

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	if (token == Keys.IS) return Is (right);
	else if (token == Keys.NOT_IS) return NotIs (right);
	return null;
    }
    
    override InfoType BinaryOpRight (Word token, Expression right) {
	if (token == Tokens.EQUAL) return AffectRight (right);
	return null;
    }

    private InfoType Is (Expression right) {
	if (this.isSame (right.info.type)) {
	    auto b = new BoolInfo ();
	    b.lintInst = &StructUtils.InstEqual;
	    return b;
	} else if (auto _cst = cast (StructCstInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    if (_cst.name == this._name) b.lintInst = &BoolUtils.InstTrue;
	    else b.lintInst = &BoolUtils.InstFalse;
	    return b;
	} else if (auto _ptr = cast (PtrInfo) right.info.type) {
	    if (_ptr && cast (VoidInfo) _ptr.content) {
		auto b = new BoolInfo ();
		b.lintInst = &StructUtils.InstEqual;
		return b;
	    }
	}
	return null;
    }    

    private InfoType NotIs (Expression right) {
	if (this.isSame (right.info.type)) {
	    auto b = new BoolInfo ();
	    b.lintInst = &StructUtils.InstNotEqual;
	    return b;
	} else if (auto _cst = cast (StructCstInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    if (_cst.name == this._name) b.lintInst = &BoolUtils.InstFalse;
	    else b.lintInst = &BoolUtils.InstTrue;
	    return b;
	} else if (auto _ptr = cast (PtrInfo) right.info.type) {
	    if (_ptr && cast (VoidInfo) _ptr.content) {
		auto b = new BoolInfo ();
		b.lintInst = &StructUtils.InstNotEqual;
		return b;
	    }
	}
	return null;
    }    
    
    private InfoType Affect (Expression right) {
	auto _st = cast (StructInfo) right.info.type;
	if (_st && _st.name == this._name) {
	    auto other = this.clone ();
	    other.lintInst = &StructUtils.InstAffect;
	    return other;
	}
	return null;
    }
    

    private InfoType AffectRight (Expression left) {
	if (cast (UndefInfo) left.info.type) {
	    auto other = this.clone ();
	    other.lintInst = &StructUtils.InstAffectRight;
	    return other;
	}
	return null;
    }    
        
    override InfoType DotOp (Var var) {
	if (var.token.str == "init") return Init ();
	else if (var.token.str == "typeid") return StringOf ();
	else {
	    foreach (it ; 0 .. this._attribs.length) {
		if (var.token.str == this._attribs [it]) {
		    return GetAttrib (it);
		}
	    }
	}
	return null;
    }

    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || this.isSame (other)) {
	    auto ret = this.clone ();
	    ret.lintInst = &StructUtils.InstAffectRight;
	    return ret;
	} else if (auto _ref = cast (RefInfo) other) {
	    if (this.isSame(_ref.content) && !this.isConst) {
		auto aux = new RefInfo (this.clone ());
		aux.lintInstS = &StructUtils.InstAddr;
		return aux;
	    }
	}
	return null;
    }
    
    override InfoType ParamOp () {
	auto ret = this.clone ();
	ret.lintInstS = &ClassUtils.InstParam;
	return ret;
    }

    override InfoType ReturnOp () {
	auto ret = this.clone ();
	ret.lintInstS = &ClassUtils.InstReturn;
	return ret;
    }    
    
    private InfoType Init () {
	auto t = this.clone ();
	t.lintInst = &StructUtils.Init;
	return t;
    }

    private InfoType StringOf () {
	auto str = new StringInfo;
	str.lintInst = &StructUtils.StringOf;
	str.leftTreatment = &StructUtils.GetStringOf;
	return str;
    }

    private InfoType GetAttrib (ulong nb) {
	auto type = this._params [nb].clone ();
	if (auto _cst = cast (StructCstInfo) type) {
	    auto word = Word.eof;
	    word.str = this._name;
	    type = _cst.create (word, []);
	}
	type.toGet = nb;
	type.lintInst = &StructUtils.Attrib;
	type.leftTreatment = &StructUtils.GetAttrib;
	type.isConst = false;
	type.setDestruct (null);
	return type;
    }    
    
    override bool isSame (InfoType other) {
	auto type = cast (StructInfo) other;
	if (type && type._name == this._name) {
	    return true;
	}
	return false;
    }
    
    override string typeString () {
	auto name = this._name ~ "(";
	foreach (it ; this._params) {
	    if (auto _st = cast(StructCstInfo) it)
		name ~= _st.name ~ "(...)";
	    else if (auto _st = cast (StructInfo) it)
		name ~= _st.name ~ "(...)";
	    else
		name ~= it.typeString ();
	    if (it !is this._params [$ - 1]) name ~= ", ";
	}
	name ~= ")";
	return name;
    }

    override InfoType clone () {
	auto ret = create (this._name, this._attribs, this._params);
	if (this._destruct is null) ret.setDestruct (null);
	return ret;
    }
    
    override InfoType cloneForParam () {
	return create (this._name, this._attribs, this._params);
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
