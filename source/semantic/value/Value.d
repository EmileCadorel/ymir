module semantic.value.Value;
 
public import semantic.types.InfoType;
import ast.Var;
import ast.ParamList;
public import ast.Expression;
import syntax.Word;
public import syntax.Tokens;
import lint.LInstList;
public import semantic.pack.Symbol;
public import syntax.Word;
public import syntax.Keys;

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
