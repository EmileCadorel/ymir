module semantic.value.BoolValue;
import semantic.value.Value;
import semantic.types.InfoType;
import ast.Var;
import ast.ParamList;
import syntax.Tokens;
import lint.LInstList;

class BoolValue : Value {

    private bool _value;

    this (bool value) {
	this._value = value;
    }

    override Value BinaryOp (Tokens token, Value right){
	if (auto t = cast (BoolValue) right) {
	    final switch (token.descr) {
	    case Tokens.DAND.descr : return new BoolValue (this._value && t._value);
	    case Tokens.DPIPE.descr : return new BoolValue (this._value || t._value);
	    case Tokens.NOT_EQUAL.descr : return new BoolValue (this._value != t._value);
	    case Tokens.DEQUAL.descr : return new BoolValue (this._value == t._value);
	    }
	}
	return null;
    }    

    override Value BinaryOpRight (Tokens token, Value left){ return null; }

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

    bool isTrue () {
	return this._value;
    }
    
    override string toString () {
	return null;
    }
    
}
