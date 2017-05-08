module semantic.types.ClassInfo;
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
import ast.Constante;
import ast.Class;


class ClassCstInfo : InfoType {

    private string _name;

    private Class _class;
    
    private bool _extern;

    this (string name, Class _class) {
	this._name = name;
	this._class = _class;
    }

    override bool isSame (InfoType other) {
	auto type = cast (ClassCstInfo) other;
	if (type && type._name == this._name) {
	    return true;
	}
	return false;
    }

    
    override ApplicationScore CallOp (Word token, ParamList params) {
	assert (false, "TODO");
    }

    
    override string simpleTypeString () {
	if (this._name [0] >= 'a' && this._name [0] <= 'z') {
	    return "_" ~ this._name;
	} else 
	    return this._name;	
    }

    override string typeString () {
	return this._name;
    }
    
    override InfoType clone () {
	return this;
    }

    /**
     Assert: Impossible de se retrouver la.
     */
    override InfoType cloneForParam () {
	assert (false, "constructeur de classe en param !?!");
    }    
    
    override bool isType () {
	return true;
    }

    string name () {
	return this._name;
    }
    
}
