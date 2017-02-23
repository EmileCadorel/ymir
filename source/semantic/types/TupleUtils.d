module semantic.types.TupleUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;;
import semantic.types.InfoType;
import syntax.Word, lint.LReg;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LSize;
import lint.LCall, lint.LAddr, semantic.types.StructInfo;
import semantic.types.TupleInfo;
import semantic.types.ClassUtils;
import lint.LFrame, std.container;
import lint.LWrite, lint.LExp;
import ast.Expression;
import ast.Constante, lint.LVisitor;

class TupleUtils {


    /**
     Affectation à droite d'un tuple.
     Params:
     llist = les instructions de l'operande de gauche
     rlist = les instructions de l'operande de droite.
     Returns: la liste des instructions du lint.
     */
    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LWrite (leftExp, rightExp);
	return inst;

    }       

    /**
     Constante de nom du type bool.
     Params:
     left = l'expression de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList TupleGetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    
    /**
     Constante de nom du type bool (nécessite BoolGetStringOf au préalable).
     Params:
     left = l'expression de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList TupleStringOf (LInstList, LInstList left) {
	return left;
    }

    
}
