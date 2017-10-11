module ymir.semantic.types.EnumUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.dtarget._;
import ymir.compiler.Compiler;

import std.container;

class EnumUtils {

    static LInstList GetAttribComp (InfoType ret, Expression left, Expression) {
	if (COMPILER.isToLint) {	    
	    auto inf = cast (EnumCstInfo) left.info.type;
	    auto list = LVisitor.visitExpressionOutSide (inf.values [ret.toGet]);
	    auto comp = inf.comps [ret.toGet];
	    if (comp) {
		for (long nb = comp.lintInstS.length - 1; nb >= 0; nb --) {
		    list = comp.lintInst (list, nb);
		}
	    }
	    return list;
	} else {
	    auto info = cast (EnumCstInfo) left.info.type;
	    auto expr = DVisitor.visitExpressionOutSide (info.values [ret.toGet]);
	    auto comp = info.comps [ret.toGet];
	    if (comp) {
		for (long nb = comp.lintInstS.length - 1 ; nb >= 0 ; nb --) {
		    expr = cast (DExpression) comp.lintInst (expr, nb);
		}
	    }
	    return expr;
	}
    }

    static LInstList GetAttrib (InfoType ret, Expression left, Expression) {
	if (COMPILER.isToLint) {
	    auto inf = cast (EnumCstInfo) left.info.type;
	    return LVisitor.visitExpressionOutSide (inf.values [ret.toGet]);
	} else {
	    auto inf = cast (EnumCstInfo) left.info.type;
	    return DVisitor.visitExpressionOutSide (inf.values [ret.toGet]);
	}
    }

    static LInstList Attrib (LInstList left, LInstList) {
	return left;
    }

    static LInstList GetMembers (InfoType ret, Expression left, Expression) {
	if (COMPILER.isToLint) {
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
	} else {
	    auto type = cast (EnumCstInfo) left.info.type;
	    auto array = new DConstArray ();
	    foreach (it ; 0 .. type.values.length) {
		auto right = DVisitor.visitExpressionOutSide (type.values [it]);
		array.addValue (right);
	    }
	    return array;
	}
    }

    static LInstList Members (LInstList llist, LInstList) {
	return llist;
    }
        
}
