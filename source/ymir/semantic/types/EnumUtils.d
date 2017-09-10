module ymir.semantic.types.EnumUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;

class EnumUtils {

    static LInstList GetAttribComp (InfoType ret, Expression left, Expression) {
	import std.stdio;
	auto inf = cast (EnumCstInfo) left.info.type;
	auto list = LVisitor.visitExpressionOutSide (inf.values [ret.toGet]);
	auto comp = inf.comps [ret.toGet];
	if (comp) {
	    for (long nb = comp.lintInstS.length - 1; nb >= 0; nb --) {
		list = comp.lintInst (list, nb);
	    }
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

    static LInstList GetMembers (InfoType ret, Expression left, Expression) {
	auto type = cast (EnumCstInfo) left.info.type;
	Array!LExp params;
	params.insertBack (new LConstDecimal (type.values.length, LSize.LONG));
	params.insertBack (new LConstDecimal (1, type.type.size, LSize.LONG));
	auto inst = new LInstList;
	auto aux = new LReg (ret.size);
	inst += new LWrite (aux, new LCall (ArrayUtils.__CstName__, params, LSize.LONG));
	foreach (it ; 0 .. type.values.length) {
	    auto right = LVisitor.visitExpressionOutSide (type.values [it]);
	    auto access = ArrayUtils.InstAccess (aux, new LConstDecimal (it, LSize.INT, type.type.size), type.type.size);
	    auto rightExp = right.getFirst;
	    inst += right;
	    inst += new LWrite (access, rightExp);
	}
	inst += aux;
	return inst;
    }

    static LInstList Members (LInstList llist, LInstList) {
	return llist;
    }
        
}
