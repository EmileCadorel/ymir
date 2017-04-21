module semantic.value.StringValue;
import semantic.value.Value;
import semantic.types.InfoType;
import ast.Var;
import ast.ParamList;
import syntax.Tokens;
import lint.LInstList;
import semantic.value.all;
import std.container, std.bigint;
import std.conv;

class StringValue : Value {

    private string _value;

    this (string value) {
	this._value = value;
    }
    
    override Value BinaryOp (Tokens token, Value right) {
	if (auto t = cast (StringValue) right) {
	    final switch (token.descr) {
	    case Tokens.PLUS.descr : return new StringValue (this._value ~ t._value);
	    case Tokens.DEQUAL.descr : return new BoolValue (this._value == t._value);
	    case Tokens.NOT_EQUAL.descr : return new BoolValue (this._value != t._value);
	    }
	}
	return null;
    }

    override Value BinaryOpRight (Tokens token, Value left) {
	return null;
    }

    override Value UnaryOp (Tokens token) {
	return null;
    }

    override Value AccessOp (ParamList params) {
	return null;
    }

    override Value AccessOp (Expression expr) {
	import std.stdio, utils.exception;
	auto id = cast (DecimalValue) expr.info.value;
	if (id && id.value.to!ulong < this._value.length) {
	    return new CharValue (this._value [id.value.to!ulong]);
	} else {
	    throw new OutOfRange (expr.info, id.value.to!ulong, this._value.length);
	}	    
    }    
    
    override Value CastOp (InfoType type) {
	return null;
    }

    override Value CompOp (InfoType type) {
	return null;
    }

    override Value CastTo (InfoType type) {
	return null;
    }

    override Value DotOp (Var var) {
	import std.conv;
	if (var.token.str == "length") return new DecimalValue (to!string (this._value.length));
	return null;
    }
    
    override LInstList toLint (Symbol sym) {
	import semantic.types.StringUtils, lint.LConst, lint.LFrame;
	import lint.LReg, lint.LWrite, lint.LCall, lint.LExp, lint.LSize;
	
	Array!LExp exps;
	exps.insertBack (new LConstDecimal (this._value.length, LSize.LONG));
	exps.insertBack (new LConstString (this._value));
	auto inst = new LInstList;
	auto it = (StringUtils.__CstName__ in LFrame.preCompiled);
	if (it is null) {
	    StringUtils.createCstString ();
	}
	if (sym.type.isDestructible) {
	    auto aux = new LReg (sym.id, sym.type.size);
	    inst += new LWrite (aux, new LCall (StringUtils.__CstName__, exps, LSize.LONG));
	    inst += aux;
	} else {
	    inst += new LCall (StringUtils.__CstName__, exps, LSize.LONG);
	}

	return inst;
    }

    
}
