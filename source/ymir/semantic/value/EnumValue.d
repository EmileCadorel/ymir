module ymir.semantic.value.EnumValue;
import ymir.semantic._;
import ymir.ast._;
import ymir.syntax._;
import ymir.lint._;

import std.bigint;
import std.conv, std.stdio;

class EnumValue : Value {

    private Value _inner;

    this (Value value) {
	this._inner = value;
    }

    
    override Value BinaryOp (Tokens t, Value r) {
	if (auto v = cast (EnumValue) r) 
	    return this._inner.BinaryOp (t, v._inner);
	return this._inner.BinaryOp (t, r);
    }

    override Value BinaryOpRight (Tokens t, Value l) {
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
	auto type = cast (EnumInfo) s.type;
	return this._inner.toLint (s, type.content);
    }
    
    override LInstList toLint (Symbol s, InfoType i) { assert (false); }

    override LInstList toLint (Expression e) { assert (false); }

    override Expression toYmir (Symbol sym) {
	return this._inner.toYmir (sym);
    }
    
}
