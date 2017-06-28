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
import semantic.impl.MethodInfo;
import std.stdio, semantic.pack.PureFrame;

/**
 Le constructeur de structure
*/
class ObjectCstInfo : InfoType {

    // La structure dérivé
    private StructCstInfo _impl;

    // Les méthodes de l'implémentation
    private Array!MethodInfo _methods;

    // Les méthodes statique de l'implémentation
    private Array!FunctionInfo _statics;

    // L'ancêtre de l'implémentation.
    private ObjectCstInfo _ancestor;
    
    private Word _locus;

    this (Word locus, StructCstInfo impl) {
	this._locus = locus;
	this._impl = impl;	
    }

    StructCstInfo impl () {
	return this._impl;
    }
    
    void setStatic (Array!FunctionInfo infos) {
	this._statics = infos;
    }

    void setMethods (Array!MethodInfo infos) {
	this._methods = infos;
    }

    void setAncestor (ObjectCstInfo ancestor) {
	this._ancestor = ancestor;
    }


    MethodInfo possessMeth (string name) {	    
	foreach (it ; this._methods) {
	    if (it.name == name) return it;
	}
	
	if (this._ancestor)
	    return this._ancestor.possessMeth (name);
	return null;
    }

    /++
     Vérifie que l'implémentation est correcte
     +/
    void verify () {	
	foreach (it ; this._methods) {
	    if (this._ancestor) {
		auto possess = this._ancestor.possessMeth (it.name);
		if (possess && !it.isOverride) {
		    throw new ImplicitOverride (it.frame.ident, possess.frame.ident);
		} else if (!possess && it.isOverride) {
		    throw new NoOverride (it.frame.ident);
		} else if (possess && it.isOverride) {
		    if (!cast (PureFrame) it.frame) {
			throw new OverrideNotPure (it.frame.ident, possess.frame.ident); 
		    } else if (!cast (PureFrame) possess.frame) {
			throw new OverrideNotPure (possess.frame.ident);
		    }

		    auto right = possess.frame.validate ();
		    auto left = it.frame.validate ();
		    if (right.vars.length != left.vars.length)
			throw new NoOverride (it.frame.ident, possess, possess.frame.ident);

		    // Le premier param est forcement différent c'est l'objet
		    foreach (it_ ; 1 .. right.vars.length) {
			if (!left.vars [it_].info.type.isSame (right.vars [it_].info.type))
			    throw new NoOverride (it.frame.ident, possess, possess.frame.ident);
		    }

		    if (!left.type.type.isSame (right.type.type))
			throw new NoOverride (it.frame.ident, possess, possess.frame.ident);		    
		}
	    }
	}
    }
    
    override InfoType DColonOp (Var var) {
	foreach (it ; this._statics) {
	    if (it.name == var.token.str) {
		return it;
	    }
	}
	
	if (this._ancestor) {
	    return this._ancestor.DColonOp (var);
	}
	return null;
    }

    override ApplicationScore CallOp (Word token, ParamList params) {
	auto ret = this._impl.CallOp (token, params);
	if (ret !is null) {
	    if (auto str = cast (StructInfo) ret.ret) {
		str.setStatics = this._statics;
		str.setMethods = this._methods;
		if (this._ancestor) {
		    str.ancestor = this._ancestor.create;
		}
	    }
	    return ret;
	} else
	    return null;
    }
    
    override InfoType CompOp (InfoType other) {
	return this.create ().CompOp (other);
    }

    StructInfo create () {
	auto info = cast (StructInfo) this._impl.create (this._locus);
	info.setStatics = this._statics;
	info.setMethods = this._methods;
	if (this._ancestor)
	    info.ancestor = this._ancestor.create;
	return info;
    }

    StructInfo create (Word name, Expression [] templates) {
	auto info = cast (StructInfo) this._impl.create (name, templates);
	info.setStatics (this._statics);
	info.setMethods (this._methods);
	if (this._ancestor)
	    info.ancestor = this._ancestor.create ();
	return info;
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
