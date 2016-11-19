module semantic.types.FloatInfo;
import syntax.Word, ast.Expression, semantic.types.FloatUtils;
import syntax.Tokens;
import semantic.types.InfoType, utils.exception;

class FloatInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new FloatInfo ();
    }

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	return null;
    }

    private InfoType Affect (Expression right) {
	if (cast(FloatInfo)right.info.type) {
	    auto f = new FloatInfo ();
	    f.lintInst = &FloatUtils.InstAffect;
	    return f;
	}
	return null;
    }
    
    override InfoType CastOp (InfoType other) {
	if (cast(FloatInfo)other !is null) return this;
	return null;
    }

    override string typeString () {
	return "float";
    }

    override InfoType clone () {
	return new FloatInfo ();
    }

    override int size () {
	return -4;
    }
    
}
