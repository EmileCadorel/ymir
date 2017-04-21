module semantic.value.Value;
 
import semantic.types.InfoType;
import ast.Var;
import ast.ParamList;
public import ast.Expression;
import syntax.Word;
public import syntax.Tokens;
import lint.LInstList;
public import semantic.pack.Symbol;

class Value {

    abstract Value BinaryOp (Tokens token, Value right);    

    abstract Value BinaryOpRight (Tokens token, Value left);

    abstract Value UnaryOp (Tokens token);

    abstract Value AccessOp (ParamList params);
    
    abstract Value AccessOp (Expression expr);

    abstract Value CastOp (InfoType type);

    abstract Value CompOp (InfoType type);

    abstract Value CastTo (InfoType type);

    abstract Value DotOp (Var attr);
    
    abstract LInstList toLint (Symbol);
    
}
