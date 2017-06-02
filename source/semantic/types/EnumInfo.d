module semantic.types.EnumInfo;
import semantic.types.InfoType;
import syntax.Word, ast.Expression, ast.Var;
import semantic.types.VoidInfo, syntax.Tokens;
import semantic.types.StructUtils, syntax.Keys;
import semantic.types.BoolInfo;
import semantic.types.UndefInfo, lint.LSize;
import semantic.types.NullInfo, std.stdio;
import std.container, semantic.types.FunctionInfo, std.outbuffer;
import ast.ParamList, semantic.pack.Frame, semantic.types.StringInfo;
import semantic.pack.Table, utils.exception, semantic.types.ClassUtils;
import semantic.types.BoolUtils, semantic.types.RefInfo;
import semantic.types.EnumUtils;

class EnumCstInfo : InfoType {

    /** Le nom de l'enum */
    private string _name;

    /** le type de l'enum (peut etre null) */
    private InfoType _type;
    
    /** Les informations de compatibilité */
    private Array!InfoType _comps;

    /** Les nom des paramètre de l'enum */
    private Array!string _names;

    /** Les valeurs de l'enum */
    private Array!Expression _values;

    this (string name, InfoType type) {
	this._name = name;
	this._type = type;
    }

    ref Array!Expression values () {
	return this._values;
    }
    
    ref Array!InfoType comps () {
	return this._comps;
    }

    ref InfoType type () {
	return this._type;
    }
    
    /**
     Ajoute une valeur à l'enum
     */
    void addAttrib (string name, Expression value, InfoType comp = null) {
	this._names.insertBack (name);
	this._values.insertBack (value);
	this._comps.insertBack (comp);
    }

    override InfoType DColonOp (Var elem) {
	ulong i = 0;
	foreach (it ; this._names) {
	    if (it == elem.token.str) {
		return GetAttrib (i);
	    }
	    i++;
	}
	return null;
    }

    InfoType create () {
	return new EnumInfo (this._name, this._type.cloneForParam ());
    }
    
    private InfoType GetAttrib (ulong nb) {
	if (this._type !is null) {
	    auto type = new EnumInfo (this._name, this._type.clone ());	    
	    type.toGet = nb;
	    type.lintInst = &EnumUtils.Attrib;
	    type.leftTreatment = &EnumUtils.GetAttribComp;
	    return type;
	} else {
	    auto type = new EnumInfo (this._name, this._values [nb].info.type.clone ());
	    type.toGet = nb;
	    type.lintInst = &EnumUtils.Attrib;
	    type.leftTreatment = &EnumUtils.GetAttrib;
	    return type;
	}
	    
    }
    
    override string simpleTypeString () {
	import std.format;
	return format ("%d%s%s)", this._name.length, "E", this._name);
    }

    override string typeString () {
	import std.format;
	if (this._type !is null)
	    return format ("%s(%s)", this._name, this._type.typeString ());
	else
	    return format ("%s(...)", this._name);
    }
    
    override bool isSame (InfoType other) {
	if (auto en = cast (EnumCstInfo) other) {
	    return en._name == this._name;
	}
	return false;
    }
    
    override InfoType clone () {
	return this;
    }

    override InfoType cloneForParam () {
	assert (false, "Pas ici");
    }

    override bool isScopable () {
	return true;
    }
    
}


class EnumInfo : InfoType {

    private string _name;
    private InfoType _content;

    this (string name, InfoType content) {
	this._name = name;
	this._content = content;
    }

    override InfoType BinaryOp (Word token, Expression right) {
	InfoType aux;
	if (auto type = cast (EnumInfo) right.info.type) {
	    aux = this._content.BinaryOp (token, type._content);	    
	} else aux = this._content.BinaryOp (token, right);
	return aux;
    }

    override InfoType BinaryOpRight (Word token, Expression left) {
	return this._content.BinaryOpRight (token, left);
    }

    override InfoType AccessOp (Word token, ParamList params) {
	return this._content.AccessOp (token, params);
    }

    override InfoType DotOp (Var var) {
	if (var.token.str == "typeid") {
	    auto str = new StringInfo;
	    str.value = new StringValue (this.typeString);
	    return str;
	}
	return this._content.DotOp (var);	
    }

    override InfoType DotExpOp (Expression var) {
	return this._content.DotExpOp (var);
    }
    
    override InfoType DColonOp (Var var) {
	return this._content.DColonOp (var);
    }       

    override InfoType UnaryOp (Word op) {
	return this._content.UnaryOp (op);
    }
    
    override InfoType CastOp (InfoType other) {
	return this._content.CastOp (other);
    }
    
    override InfoType CompOp (InfoType other) {
	if (cast (UndefInfo) other || this.isSame (other)) {
	    auto rf = this.clone ();
	    auto ret = this._content.CompOp (this._content);	    
	    rf.lintInst = ret.lintInst;
	    return rf;
	} else {
	    return this._content.CompOp (other);
	}	
    }

    override InfoType ApplyOp (Array!Var vars) {
	return this._content.ApplyOp (vars);
    }    

    override string simpleTypeString () {
	import std.format;
	return format ("%d%s%s", this._name.length, "E", this._name);
    }

    override string typeString () {
	import std.format;
	return format ("%s(%s)", this._name, this._content.typeString ());
    }
    
    override bool isSame (InfoType other) {
	if (auto en = cast (EnumInfo) other) {
	    if (en._name == this._name
		&& this._content.isSame (en._content)) return true;
	}
	return false;
    }

    override InfoType clone () {
	return new EnumInfo (this._name, this._content.clone ());
    }

    override InfoType cloneForParam () {
	return new EnumInfo (this._name, this._content.cloneForParam ());
    }

    override LSize size () {
	return this._content.size;
    }
    
}
