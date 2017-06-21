module semantic.impl.ObjectInfo;
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
import semantic.types.DecimalInfo;
import ast.Constante, semantic.types.StructInfo;
import semantic.pack.Namespace;

/**
 Le constructeur de structure
*/
class ObjectCstInfo : InfoType {

    // La structure dérivé
    private StructCstInfo _impl;

    // Les méthodes de l'implémentation
    private Array!FunctionInfo _methods;

    // Les méthodes statique de l'implémentation
    private Array!FunctionInfo _statics;


    this (StructCstInfo impl) {
	this._impl = impl;	
    }

    StructCstInfo impl () {
	return this._impl;
    }
    
    void setStatic (Array!FunctionInfo infos) {
	this._statics = infos;
    }

    void setMethods (Array!FunctionInfo infos) {
	this._methods = infos;
    }
    
    override InfoType DColonOp (Var var) {
	foreach (it ; this._statics) {
	    if (it.name == var.token.str) {
		return it;
	    }
	}
	return null;
    }

    override ApplicationScore CallOp (Word token, ParamList params) {
	auto ret = this._impl.CallOp (token, params);
	if (ret !is null) {
	    if (auto str = cast (StructInfo) ret.ret) {
		str.setStatics = this._statics;
		str.setMethods = this._methods;
	    }
	    return ret;
	} else
	    return null;
    }

    override string simpleTypeString () {
	import std.format;
	return format ("IM%s", this._impl.simpleTypeString);
    }

    override string typeString () {
	import std.format;
	return format("impl %s", this._impl.typeString);
    }
    
    override InfoType clone () {
	return this;	
    }

    override InfoType cloneForParam () {
	assert (false);
    }

    override bool isSame (InfoType) {
	return false;
    }
        
}
