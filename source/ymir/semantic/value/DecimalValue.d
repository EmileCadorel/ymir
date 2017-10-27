module ymir.semantic.value.DecimalValue;
import ymir.semantic._;
import ymir.ast._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.dtarget._;
import ymir.compiler.Compiler;

import std.bigint;
import std.conv;

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

    override Value UnaryOp (Word op) {
	if (op == Tokens.MINUS) return new DecimalValue (- this._value);
	else if (op == Tokens.DPLUS) return new DecimalValue (this._value++);
	else if (op == Tokens.DMINUS) return new DecimalValue (this._value --);
	return null;
    }

    override Value AccessOp (ParamList params) {	
	return null;
    }
    
    override Value AccessOp (Expression) {	
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

    BigInt value () {
	return this._value;
    }

    T get (T) () {
	return this._value.to!T;
    }    
    
    override LInstList toLint (Symbol sym, InfoType type) {
	auto info = cast (DecimalInfo) (type);
	auto cst = info.type;
	try {
	    if (COMPILER.isToLint) {
		final switch (cst.id) {
		case DecimalConst.BYTE.id : return new LInstList (new LConstDecimal (this._value.to!byte, LSize.BYTE));
		case DecimalConst.UBYTE.id : return new LInstList (new LConstDecimal (this._value.to!ubyte, LSize.UBYTE));
		case DecimalConst.SHORT.id : return new LInstList (new LConstDecimal (this._value.to!short, LSize.SHORT));
		case DecimalConst.USHORT.id : return new LInstList (new LConstDecimal (this._value.to!ushort, LSize.USHORT));
		case DecimalConst.INT.id : return new LInstList (new LConstDecimal (this._value.to!int, LSize.INT));
		case DecimalConst.UINT.id : return new LInstList (new LConstDecimal (this._value.to!uint, LSize.UINT));
		case DecimalConst.LONG.id : return new LInstList (new LConstDecimal (this._value.to!long, LSize.LONG));
		case DecimalConst.ULONG.id : return new LInstList (new LConstDecimal (this._value.to!ulong, LSize.ULONG));    
		}
	    
	    } else {
		return new DCast (new DType (fromDecimalConst (cst)), new DDecimal (cst, this._value));
	    }
	} catch (ConvOverflowException exp) {
	    throw new CapacityOverflow (sym, this._value.to!string);
	}
    }

    override LInstList toLint (Symbol sym) {
	try {
	    if (COMPILER.isToLint) {
		if (sym) {
		    return toLint (sym, sym.type);
		} else {
		    return new LInstList (new LConstDecimal (this._value.to!ulong, LSize.ULONG));    
		}
	    } else {
		return new DCast (new DType (fromDecimalConst ((cast (DecimalInfo) sym.type).type)),
				  new DDecimal ((cast (DecimalInfo) sym.type).type, this._value)); 
	    }
	} catch (ConvOverflowException exp) {
	    throw new CapacityOverflow (sym, this._value.to!string);
	}
    }

    override Expression toYmir (Symbol sym) {
	auto word = Word.eof ;
	word.str = this._value.to!string;
	auto dec = cast (DecimalInfo) sym.type;
	auto ret = new Decimal (word, dec.type);
	ret.info = sym;
	return ret;
    }
    
    override string toString () {
	return this._value.to!string;
    }
    
}
