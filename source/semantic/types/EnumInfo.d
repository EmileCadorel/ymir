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

    /** Les informations de compatibilité */
    private Array!InfoType _comps;

    /** Les nom des paramètre de l'enum */
    private Array!string _names;

    /** Les valeurs de l'enum */
    private Array!Expression _values;

    this (string name) {
	this._name = name;
    }

    ref Array!Expression values () {
	return this._values;
    }
    
    /**
     Ajoute une valeur à l'enum
     */
    void addAttrib (string name, Expression value, InfoType comp) {
	this._names.insertBack (name);
	this._values.insertBack (value);
	this._comps.insertBack (comp);
    }

    override InfoType DotOp (Var elem) {
	foreach (it ; 0 .. this._names.length) {
	    if (elem.token.str == this._names [it]) {
		return GetAttrib (it);
	    }
	}
	return null;
    }    

    private InfoType GetAttrib (ulong nb) {
	auto type = this._values [nb].info.type.clone ();
	type.toGet = nb;
	type.lintInst = &EnumUtils.Attrib;
	type.leftTreatment = &EnumUtils.GetAttrib;
	return type;	
    }
    
    override bool isSame (InfoType other) {
	if (auto en = cast (EnumCstInfo) other) {
	    return en._name == this._name;
	}
	return false;
    }

    override string simpleTypeString () {
	if (this._name [0] >= 'a' && this._name [0] <= 'z') {
	    return "_" ~ this._name;
	} else 
	    return this._name;
    }
    
    override string typeString () {
	return "enum:" ~ this._name;
    }
    
    override InfoType clone () {
	return this;
    }

    override InfoType cloneForParam () {
	assert (false, "Pas ici");
    }
    
}
