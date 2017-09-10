module ymir.semantic.value.Value;
import ymir.semantic._;
import ymir.ast._;
import ymir.syntax._;
import ymir.lint._; 

class Value {

    Value BinaryOp (Tokens token, Value right) { return null; }

    Value BinaryOpRight (Tokens token, Value left) { return null; }

    Value BinaryOpRight (Keys token, Value left) { return null; }

    Value UnaryOp (Word token) { return null; }

    Value AccessOp (ParamList params) { return null; }
    
    Value AccessOp (Expression expr) { return null; }

    Value CastOp (InfoType type) { return null; }

    Value CompOp (InfoType type) { return null; }

    Value CastTo (InfoType type) { return null; }

    Value DotOp (Var attr) { return null; }
    
    LInstList toLint (Symbol) { assert (false); }
    
    LInstList toLint (Symbol, InfoType) { assert (false); }

    LInstList toLint (Expression) { assert (false); }
    
}
