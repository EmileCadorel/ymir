module semantic.types.EnumUtils;
import lint.LInstList;
import lint.LVisitor;
import semantic.types.InfoType;
import semantic.types.EnumInfo;
import ast.Expression;

class EnumUtils {

    static LInstList GetAttribComp (InfoType ret, Expression left, Expression) {
	auto inf = cast (EnumCstInfo) left.info.type;
	auto list = LVisitor.visitExpressionOutSide (inf.values [ret.toGet]);
	auto comp = inf.comps [ret.toGet];
	for (long nb = comp.lintInstS.length - 1; nb >= 0; nb --) {
	    list = comp.lintInst (list, nb);
	}
	return list;
    }

    static LInstList GetAttrib (InfoType ret, Expression left, Expression) {
	auto inf = cast (EnumCstInfo) left.info.type;
	return LVisitor.visitExpressionOutSide (inf.values [ret.toGet]);
    }

    static LInstList Attrib (LInstList left, LInstList) {
	return left;
    }

}
