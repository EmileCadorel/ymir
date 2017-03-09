module semantic.types.EnumUtils;
import lint.LInstList;
import lint.LVisitor;
import semantic.types.InfoType;
import semantic.types.EnumInfo;
import ast.Expression;

class EnumUtils {

    static LInstList GetAttrib (InfoType ret, Expression left, Expression) {
	auto inf = cast (EnumCstInfo) left.info.type;
	return LVisitor.visitExpressionOutSide (inf.values [ret.toGet]);
    }

    static LInstList Attrib (LInstList, LInstList left) {
	return left;
    }

}
