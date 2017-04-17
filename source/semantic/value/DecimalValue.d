module semantic.value.DecimalValue;

import semantic.value.Value;
import semantic.types.InfoType;
import ast.Var;
import ast.ParamList;
import syntax.Word;
import semantic.value.BoolValue;
import std.bigint;
import utils.Matching;
import std.conv;
import lint.LInstList;

class DecimalValue : Value {

    private BigInt _value;
    
    this (string value) {
	this._value = BigInt (value);
    }

    this (BigInt value) {
	this._value = value;
    }
    
    override Value BinaryOp (Tokens token, Value right) {
	if (auto t = match!DecimalValue (right)) {
	    final switch (token.descr) {
	    case Tokens.DAND.descr : return new BoolValue (this._value && t._value);
	    case Tokens.DPIPE.descr : return new BoolValue (this._value || t._value);
	    case Tokens.INF.descr : return new BoolValue (this._value < t._value);
	    case Tokens.SUP.descr : return new BoolValue (this._value > t._value);
	    case Tokens.INF_EQUAL.descr : return new BoolValue (this._value <= t._value);
	    case Tokens.SUP_EQUAL.descr : return new BoolValue (this._value >= t._value);
	    case Tokens.NOT_EQUAL.descr : return new BoolValue (this._value != t._value);
	    case Tokens.NOT_INF.descr : return new BoolValue (!(this._value < t._value));
	    case Tokens.NOT_SUP.descr : return new BoolValue (!(this._value > t._value));
	    case Tokens.NOT_INF_EQUAL.descr : return new BoolValue (!(this._value <= t._value));
	    case Tokens.NOT_SUP_EQUAL.descr : return new BoolValue (!(this._value >= t._value));
	    case Tokens.DEQUAL.descr : return new BoolValue (this._value == t._value);
	    case Tokens.PLUS.descr : return new DecimalValue (this._value + t._value);
	    case Tokens.MINUS.descr : return new DecimalValue (this._value - t._value);
	    case Tokens.DIV.descr : {
		if (t._value != 0) 
		    return new DecimalValue (this._value / t._value);
		else return null;
	    }
	    case Tokens.STAR.descr : return new DecimalValue (this._value * t._value);
	    case Tokens.PIPE.descr : return new DecimalValue (this._value | t._value);
	    case Tokens.AND.descr : return new DecimalValue (this._value & t._value);
	    case Tokens.LEFTD.descr : return new DecimalValue (this._value << (t._value.to!long));
	    case Tokens.RIGHTD.descr :  return new DecimalValue (this._value >> (t._value.to!long));
	    case Tokens.XOR.descr : return new DecimalValue (this._value ^ (t._value.to!long));
	    case Tokens.PERCENT.descr : return new DecimalValue (BigInt (this._value % (t._value.to!long)));
	    case Tokens.DXOR.descr : return new DecimalValue (this._value ^^ (t._value.to!long));
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

    override Value AccessOp (Tokens op, ParamList params) {
	return null;
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

    override Value DotOp (Var attr) {
	return null;
    }   

    override LInstList toLint (Symbol sym) {
	import lint.LConst, lint.LSize;
	return new LInstList (new LConstDecimal (this._value.to!long, LSize.LONG));
    }

    override string toString () {
	return this._value.to!string;
    }
    
}
