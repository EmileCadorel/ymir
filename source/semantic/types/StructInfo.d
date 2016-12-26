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


/**
 Le constructeur de structure
*/
class StructCstInfo : InfoType {

    private string _name;
    private Array!InfoType _params;
    private Array!string _names;

    this (string name) {
	this._name = name;
    }

    void addAttrib (string name, InfoType type) {
	this._names.insertBack (name);
	this._params.insertBack (type);
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
	auto score = new ApplicationScore (token);
	foreach (it ; 0 .. this._params.length) {
	    auto info = this._params [it];
	    auto type = params.params [it].info.type.CompOp (info);
	    if (info.isSame (type)) {
		score.score += Frame.SAME;
		score.treat.insertBack (type);
	    } else if (type !is null) {
		score.score += Frame.AFF;
		score.treat.insertBack (type);
	    } else return null;
	}
	
	auto ret = StructInfo.create (this._name, this._names, this._params);
	ret.lintInstMult = &StructUtils.InstCall;
	ret.leftTreatment = &StructUtils.InstCreateCst;
	score.dyn = true;
	score.ret = ret;
	return score;
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
    
    override InfoType BinaryOpRight (Word token, Expression right) {
	if (token == Tokens.EQUAL) return AffectRight (right);
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
