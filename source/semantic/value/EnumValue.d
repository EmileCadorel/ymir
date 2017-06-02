module semantic.value.EnumValue;

import semantic.value.Value;
import semantic.types.InfoType;
import ast.Var;
import ast.ParamList;
import syntax.Word;
import semantic.value.BoolValue;
import std.bigint;
import utils.Matching;
import std.conv, std.stdio;
import lint.LInstList;
import lint.LConst, lint.LSize;
import ast.Constante, semantic.types.DecimalInfo;

class EnumValue : Value {

    private Value _inner;

    this (Value value) {
	this._inner = value;
    }

    
    override Value BinaryOp (Tokens t, Value r) {
	writeln ("ici");
	if (auto v = cast (EnumValue) r) 
	    return this._inner.BinaryOp (t, v._inner);
	return this._inner.BinaryOp (t, r);
    }

    override Value BinaryOpRight (Tokens t, Value l) {
	writeln ("ici");
	return this._inner.BinaryOpRight (t, l);
    }

    override Value BinaryOpRight (Keys t, Value l) { return this._inner.BinaryOpRight (t, l); }

    override Value UnaryOp (Word t) { return this._inner.UnaryOp (t); }

    override Value AccessOp (ParamList p) { return this._inner.AccessOp (p); }
    
    override Value AccessOp (Expression e) { return this._inner.AccessOp (e); }

    override Value CastOp (InfoType t) { return this._inner.CastOp (t); }

    override Value CompOp (InfoType t) { return this._inner.CompOp (t); }

    override Value CastTo (InfoType t) { return this._inner.CastTo (t); }

    override Value DotOp (Var a) { return this._inner.DotOp (a); }
    
    override LInstList toLint (Symbol s) {
	import semantic.types.EnumInfo;
	auto type = cast (EnumInfo) s.type;
	return this._inner.toLint (s, type.content);
    }
    
    override LInstList toLint (Symbol s, InfoType i) { assert (false); }

    override LInstList toLint (Expression e) { assert (false); }

}
