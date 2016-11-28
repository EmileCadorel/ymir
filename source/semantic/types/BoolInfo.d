module semantic.types.BoolInfo;
import syntax.Word, ast.Expression;
import semantic.types.CharInfo;
import semantic.types.InfoType, utils.exception;
import syntax.Tokens, semantic.types.BoolUtils;

class BoolInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new BoolInfo ();
    }

    override InfoType BinaryOp (Word op, Expression right) {
	if (op == Tokens.EQUAL) return Affect (right);
	if (op == Tokens.DAND) return opNorm !(Tokens.DAND) (right);
	if (op == Tokens.DPIPE) return opNorm !(Tokens.DPIPE) (right);
	if (op == Tokens.NOT_EQUAL) return opNorm!(Tokens.NOT_EQUAL) (right);
	if (op == Tokens.DEQUAL) return opNorm!(Tokens.DEQUAL) (right);
	return null;
    }

    private InfoType Affect (Expression right) {
	if (cast(BoolInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &BoolUtils.InstAffect;
	    return b;
	}
	return null;
    }
    
    private InfoType opNorm (Tokens op) (Expression right) {
	if (cast(BoolInfo) right.info.type) {
	    auto b = new BoolInfo ();
	    b.lintInst = &BoolUtils.InstOp !(op);
	    return b;
	}
	return null;
    }

    override string typeString () {
	return "bool";
    }

    override InfoType CastOp (InfoType other) {
	if (cast(BoolInfo)other) return this;
	else if (cast (CharInfo) other) {
	    auto aux = new CharInfo;
	    aux.lintInstS = &BoolUtils.InstCastChar ;
	    return aux;
	}
	return null;
    }
    
    override InfoType clone () {
	return new BoolInfo ();
    }

    override int size () {
	return 1;
    }
    
}
