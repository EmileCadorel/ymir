module semantic.value.CharValue;
import semantic.value.all;
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
	    if (op == Tokens.PLUS) return new CharValue (cast (char) (this._value + ch._value));
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
	    if (op == Tokens.PLUS) return new DecimalValue (this._value.to!int + dec.value);
	    if (op == Tokens.MINUS) return new DecimalValue (this._value.to!int - dec.value);
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
	    if (op == Tokens.PLUS) return new DecimalValue (dec.value + this._value.to!int);
	    if (op == Tokens.MINUS) return new DecimalValue (dec.value - this._value.to!int);
	}
	return null;
    }

    override Value UnaryOp (Tokens token){ return null; }

    override Value AccessOp (ParamList params){ return null; }
    
    override Value AccessOp (Expression){ return null; }

    override Value CastOp (InfoType type){ return null; }

    override Value CompOp (InfoType type){ return null; }

    override Value CastTo (InfoType type){ return null; }

    override Value DotOp (Var attr){ return null; }
       
    override LInstList toLint (Symbol sym) {
	import lint.LConst, lint.LSize;
	if (this._value)
	    return new LInstList (new LConstDecimal (true, LSize.BYTE));
	else return new LInstList (new LConstDecimal (false, LSize.BYTE));
    }       

    char value () {
	return this._value;
    }
    
    override string toString () {
	return null;
    }
    
}
