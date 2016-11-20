module semantic.types.StringInfo;
import syntax.Word, ast.Expression, syntax.Tokens;
import semantic.types.InfoType, utils.exception;
import semantic.types.StringUtils, ast.ParamList;
import semantic.types.CharInfo, semantic.types.IntInfo;

class StringInfo : InfoType {

    static InfoType create (Word token, Expression [] templates) {
	if (templates.length != 0)
	    throw new NotATemplate (token);
	return new StringInfo ();
    }

    override InfoType BinaryOp (Word token, Expression right) {
	if (token == Tokens.EQUAL) return Affect (right);
	else return null;
    }

    private InfoType Affect (Expression right) {
	if (cast(StringInfo)right.info.type) {
	    auto str = new StringInfo ();
	    str.lintInst = &StringUtils.InstAffect;
	    return str;
	}
	return null;
    }    
    
    override InfoType CastOp (InfoType info) {
	if (cast (StringInfo)info) return this;
	return null;
    }

    override InfoType AccessOp (Word token, ParamList params) {
	if (params.params.length == 1) {
	    return Access (params.params [0]);
	} else {
	    return null;
	}
    }

    private InfoType Access (Expression expr) {
	if (cast(IntInfo) expr.info.type) {
	    auto ch = new CharInfo;
	    ch.lintInstMult = &StringUtils.InstAccessS;
	    return ch;
	}
	return null;
    }
    
    override string typeString () {
	return "string";
    }

    override InfoType clone () {
	return new StringInfo ();
    }

    override int size () {
	return 8;
    }
    
}

