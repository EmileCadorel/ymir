module semantic.value.CharValue;
import semantic.value._;
import semantic.types.InfoType;
import ast.Var;
import ast.ParamList;
import syntax.Tokens;
import lint.LInstList;
import std.conv;

class CharValue : Value {

    private char _value;

    this (char value) {
	this._value = value;
    }

    override Value BinaryOp (Tokens op, Value right) {
	import std.stdio;
	if (auto ch = cast (CharValue) right) {
	    if (op == Tokens.INF) return new BoolValue (this._value < ch._value);
	    if (op == Tokens.SUP) return new BoolValue (this._value > ch._value);
	    if (op == Tokens.SUP_EQUAL) return new BoolValue (this._value >= ch._value);
	    if (op == Tokens.INF_EQUAL) return new BoolValue (this._value <= ch._value);
	    if (op == Tokens.NOT_EQUAL) return new BoolValue (this._value != ch._value);
	    if (op == Tokens.NOT_INF) return new BoolValue (this._value >= ch._value);
	    if (op == Tokens.NOT_SUP) return new BoolValue (this._value <= ch._value);
	    if (op == Tokens.NOT_SUP_EQUAL) return new BoolValue (this._value < ch._value);

	    if (op == Tokens.NOT_INF_EQUAL) return new BoolValue (this._value > ch._value);
	    if (op == Tokens.DEQUAL) return new BoolValue (this._value == ch._value);
	    if (op == Tokens.PLUS) return new CharValue (cast (char) (cast(int)(this._value) + cast(int)(ch._value)));	    
	    if (op == Tokens.MINUS) return new CharValue (cast (char) (this._value - ch._value));	    
	} else if (auto dec = cast (DecimalValue) right) {
	    if (op == Tokens.INF) return new BoolValue (this._value.to!int < dec.value);
	    if (op == Tokens.SUP) return new BoolValue (this._value.to!int > dec.value);
	    if (op == Tokens.SUP_EQUAL) return new BoolValue (this._value.to!int >= dec.value);
	    if (op == Tokens.INF_EQUAL) return new BoolValue (this._value.to!int <= dec.value);
	    if (op == Tokens.NOT_EQUAL) return new BoolValue (this._value.to!int != dec.value);
	    if (op == Tokens.NOT_INF) return new BoolValue (this._value.to!int >= dec.value);
	    if (op == Tokens.NOT_SUP) return new BoolValue (this._value.to!int <= dec.value);
	    if (op == Tokens.NOT_SUP_EQUAL) return new BoolValue (this._value.to!int < dec.value);

	    if (op == Tokens.NOT_INF_EQUAL) return new BoolValue (this._value.to!int > dec.value);
	    if (op == Tokens.DEQUAL) return new BoolValue (this._value.to!int == dec.value);
	    if (op == Tokens.PLUS) return new CharValue ((this._value.to!int + dec.value).to!char);
	    if (op == Tokens.MINUS) return new CharValue ((this._value.to!int - dec.value).to!char);
	} else if (auto str = cast (StringValue) right) {
	    if (op == Tokens.DEQUAL) return new BoolValue (str.value.length == 1 && str.value [0] == this._value);
	}
	return null;
    }    

    override Value BinaryOpRight (Tokens op, Value left) {
	if (auto dec = cast (DecimalValue) left) {
	    if (op == Tokens.INF) return new BoolValue (dec.value < this._value.to!int);
	    if (op == Tokens.SUP) return new BoolValue (dec.value > this._value.to!int);
	    if (op == Tokens.SUP_EQUAL) return new BoolValue (dec.value >= this._value.to!int);
	    if (op == Tokens.INF_EQUAL) return new BoolValue (dec.value <= this._value.to!int);
	    if (op == Tokens.NOT_EQUAL) return new BoolValue (dec.value != this._value.to!int);
	    if (op == Tokens.NOT_INF) return new BoolValue (dec.value >= this._value.to!int);
	    if (op == Tokens.NOT_SUP) return new BoolValue (dec.value <= this._value.to!int);
	    if (op == Tokens.NOT_SUP_EQUAL) return new BoolValue (dec.value < this._value.to!int);

	    if (op == Tokens.NOT_INF_EQUAL) return new BoolValue (dec.value > this._value.to!int);
	    if (op == Tokens.DEQUAL) return new BoolValue (dec.value == this._value.to!int);
	    if (op == Tokens.PLUS) return new CharValue ((dec.value + this._value.to!int).to!char);
	    if (op == Tokens.MINUS) return new CharValue ((dec.value - this._value.to!int).to!char);
	}
	return null;
    }

    override Value UnaryOp (Word token){ return null; }

    override Value AccessOp (ParamList params){ return null; }
    
    override Value AccessOp (Expression){ return null; }

    override Value CastOp (InfoType type){ return null; }

    override Value CompOp (InfoType type){ return null; }

    override Value CastTo (InfoType type){ return null; }

    override Value DotOp (Var attr){ return null; }
       
    override LInstList toLint (Symbol) {
	import lint.LConst, lint.LSize;
	return new LInstList (new LConstDecimal (this._value.to!long, LSize.BYTE));
    }       

    override LInstList toLint (Symbol, InfoType) {
	import lint.LConst, lint.LSize;
	return new LInstList (new LConstDecimal (this._value.to!long, LSize.BYTE));
    }       

    
    char value () {
	return this._value;
    }
    
    override string toString () {
	return "'" ~ to!string(this._value) ~ "'";
    }
    
}
