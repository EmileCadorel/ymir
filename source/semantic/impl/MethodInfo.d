module semantic.impl.MethodInfo;
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
import std.stdio;


class MethodInfo : FunctionInfo {

    this (Namespace space, string name, Frame info) {
	super (space, name);
	this.set (info);
	super.alone = true;
    }
    
}
