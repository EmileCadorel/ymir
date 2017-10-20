module ymir.semantic.types.StructUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.dtarget._;
import ymir.compiler.Compiler;

import std.container, std.stdio;

class StructUtils {
    
    static string __CstName__ = "_YPCstStruct";
    static string __CstNameEmpty__ = "_YPCstStructEmpty";
   
    static LInstList AssocBlock (StructInfo info, LReg alloc, ref Array!LReg regs) {
	auto interne = new LInstList;
	LExp retReg, ancSize, left;
	if (info.ancestor) {
	    interne = AssocBlockEmpty (info.ancestor, alloc);
	    auto bin = cast (LBinop) interne.getFirst ();
	    retReg = bin;
	    left = bin.left;
	    ancSize = bin.right;
	} else {
	    retReg = alloc;
	    left = retReg;
	    ancSize = new LConstDecimal (0, LSize.LONG);
	}
	
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	auto size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	foreach (fr ; info.methods) {
	    if (cast (PureFrame) fr.frame) {
		LExp lExp;
		if (fr.isOverride) {
		    auto pos = info.ancestor.DotOp (new Var (fr.frame.ident));
		    auto getMeth = pos.leftTreatment (pos, new Type (fr.frame.ident, info.ancestor), null);
		    auto regReadMeth = cast (LRegRead) (getMeth.getFirst);
		    lExp = new LRegRead (left, regReadMeth.begin, LSize.ULONG);
		} else {
		    nbUlong ++;
		    lExp = new LRegRead (retReg, size, LSize.ULONG);
		}
		auto proto = fr.frame.validate;		
		auto rExp = new LConstFunc (Mangler.mangle!"function" (proto.name, proto));
		interne += new LWrite (lExp, rExp);
		size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	    }
	}

	foreach (it ; info.params) {
	    final switch (it.size.id) {
	    case LSize.ULONG.id: nbUlong ++; break;
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.UINT.id: nbUint ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.USHORT.id: nbUshort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.UBYTE.id: nbUbyte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }
	    
	    regs.insertBack (new LReg (it.size));
	    auto type = it.CompOp (new UndefInfo);
	    if (type !is null) {
		LInstList rlist = new LInstList (regs.back ());
		LInstList llist = new LInstList (new LRegRead (retReg, size, it.size));
		for (long nb = type.lintInstSR.length - 1; nb >= 0; nb --)
		    rlist = type.lintInstR (rlist, nb);
		interne += type.lintInst (llist, rlist);
	    } else if (auto str = cast (StructCstInfo) it) {
		auto rExp = regs.back ();
		auto lExp = new LRegRead (retReg, size, it.size);
		interne += new LWrite (lExp, rExp);
	    } else assert (false, typeid (it).toString);
	    
	    size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);	
	}
	
	interne += new LBinop (left, new LBinop (size, ancSize, Tokens.PLUS), Tokens.PLUS);
	return interne;
    }

    static LInstList AssocBlockEmpty (StructInfo info, LReg alloc) {
	auto interne = new LInstList;
	LExp retReg, ancSize, left;
	if (info.ancestor) {
	    interne = AssocBlockEmpty (info.ancestor, alloc);
	    auto bin = cast (LBinop) interne.getFirst (); 
	    retReg = bin;
	    left = bin.left;
	    ancSize = bin.right;
	} else {
	    retReg = left = alloc;
	    ancSize = new LConstDecimal (0, LSize.LONG);
	}
	
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	auto size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	foreach (fr ; info.methods) {
	    if (cast (PureFrame) fr.frame) {
		LExp lExp;
		if (fr.isOverride) {
		    auto pos = info.ancestor.DotOp (new Var (fr.frame.ident));
		    auto getMeth = pos.leftTreatment (pos, new Type (fr.frame.ident, info.ancestor), null);
		    auto regReadMeth = cast (LRegRead) (getMeth.getFirst);
		    lExp = new LRegRead (left, regReadMeth.begin, LSize.ULONG);
		} else {
		    nbUlong ++;
		    lExp = new LRegRead (retReg, size, LSize.ULONG);
		}
		auto proto = fr.frame.validate;
		auto rExp = new LConstFunc (Mangler.mangle!"function" (proto.name, proto));
		interne += new LWrite (lExp, rExp);
		size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	    }
	}

	foreach (it ; info.params) {
	    final switch (it.size.id) {
	    case LSize.ULONG.id: nbUlong ++; break;
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.UINT.id: nbUint ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.USHORT.id: nbUshort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.UBYTE.id: nbUbyte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }
	    

	    auto lExp = (new LRegRead (retReg, size, it.size));
	    if (it.size != LSize.FLOAT && it.size != LSize.DOUBLE)
		interne += new LWrite (lExp, new LConstDecimal (0, it.size));
	    else
		interne += new LWrite (lExp, new LConstDouble (0));	    
	    size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);	
	}
	
	interne += new LBinop (left, new LBinop (size, ancSize, Tokens.PLUS), Tokens.PLUS);
	return interne;
    }
    
    
    static void createCstStruct (StructInfo info) {
	if (COMPILER.isToLint) {
	    string name = Mangler.mangle!"struct" (info);
	    auto last = LReg.lastId;
	    LReg.lastId = 0;
	    Array!LReg regs;
	    auto retReg = new LReg (LSize.LONG);
	    auto entry = new LLabel (new LInstList), end = new LLabel;
	    
	    
	    auto interne = AssocBlock (info, retReg, regs);
	    auto bin = cast (LBinop) interne.getFirst ();
	    auto size = bin.right;
	    
	    entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);
	    entry.insts += interne;
	    
	    auto fr = new LFrame (__CstName__ ~ name, entry, end, retReg, regs);
	    fr.isStd = false;
	    LFrame.preCompiled [__CstName__ ~ name] = fr;	
	    LReg.lastId = last;
	    createSimpleCstStruct (info, name);
	} else {
	    COMPILER.getLVisitor!(DVisitor).addStructToCst (info);
	}
    }
    
    static void createSimpleCstStruct (StructInfo info, string name) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	Array!LReg regs;
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;

       	auto interne = AssocBlockEmpty (info, retReg);
	auto bin = cast (LBinop) interne.getFirst ();
	auto size = bin.right;
	
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);	
	entry.insts += interne;
	
	auto fr = new LFrame (__CstNameEmpty__ ~ name, entry, end, retReg, regs);
	fr.isStd = false;
	LFrame.preCompiled [__CstNameEmpty__ ~ name] = fr;	
	LReg.lastId = last;
    }
    
    static LInstList InstCreateCst (bool _extern) (InfoType _type, Expression, Expression) {
	if (COMPILER.isToLint) {
	    auto type = cast (StructInfo) _type;
	    string name = Mangler.mangle!"struct" (type);
	    if (!_extern) {
		auto it = (__CstName__ ~ name) in LFrame.preCompiled;
		if (it is null) createCstStruct (type);
	    }
	    auto inst = new LInstList ();
	    inst += new LConstFunc (__CstName__ ~ name);
	    return inst;
	} else {
	    auto type = cast (StructInfo) _type;
	    COMPILER.getLVisitor!(DVisitor).addStructToCst (type);
	    return new DVar (type.name);
	}
    }

    static LInstList InstCreateCstEmpty (bool _extern) (InfoType _type, Expression, Expression) {
	if (COMPILER.isToLint) {
	    auto type = cast (StructInfo) _type;
	    string name = Mangler.mangle!"struct" (type);
	    if (!_extern) {
		auto it = (__CstName__ ~ name) in LFrame.preCompiled;
		if (it is null) createCstStruct (type);
	    }
	    auto inst = new LInstList ();
	    inst += new LConstFunc (__CstNameEmpty__ ~ name);
	    return inst;
	} else {
	    auto type = cast (StructInfo) _type;
	    COMPILER.getLVisitor!(DVisitor).addStructToCst (type);
	    return new DVar (type.name);	
	}
    }
    
    static LInstList InstCall (LInstList llist, Array!LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    Array!LExp params;
	    inst += llist;
	    foreach (it ; rlist) {
		auto exp = it.getFirst ();
		inst += it;
		if (auto call = cast (LCall) exp) {
		    auto aux = new LReg (call.size);
		    inst += new LWrite (aux, call);
		    exp = aux;
		}
		params.insertBack (exp);
	    }
	    
	    inst += new LCall ((cast (LConstFunc) leftExp).name, params, LSize.LONG);
	    return inst;
	} else {
	    return new DRealNew (new DPar (cast (DExpression) llist, cast (DParamList) rlist [0])); 
	}
    }

    static LInstList InstCallEmpty (LInstList llist, Array!LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    Array!LExp params;
	    inst += llist;
	    inst += new LCall ((cast (LConstFunc) leftExp).name, params, LSize.LONG);
	    return inst;
	} else {
	    return new DNew (new DPar (cast (DExpression) llist, new DParamList));
	}
    }    

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    
	    inst += new LWrite (leftExp, rightExp);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.EQUAL);
	}
    }    
    
    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    
	    inst += new LWrite (leftExp, rightExp);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.EQUAL);
	}
    }

    static LInstList InstAffectNull (LInstList llist, LInstList) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    
	    inst += new LWrite (leftExp, new LConstDecimal (0, LSize.LONG));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DNull, Tokens.EQUAL);
	}
    }    

    
    static LInstList InstDestruct (LInstList llist) {
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	return inst;
    }
    
    static LInstList Init (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    return new LInstList (new LConstDecimal (0, LSize.LONG));
	} else {
	    return new DNull ();
	}
    }

    static LInstList GetAttribFromAncestor (ref bool done, StructInfo info, ref ulong nb, LSize retSize) {
	LInstList inst;
	LExp size;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	if (info.ancestor) {
	    inst = GetAttribFromAncestor (done, info.ancestor, nb, retSize);
	    if (done) return inst;
	    size = inst.getFirst ();
	} else {
	    inst = new LInstList;
	    size = new LConstDecimal(0, LSize.LONG);
	}
	
	nbUlong += info.nbMethods;		
	auto toGet = nb < info.params.length ? nb : info.params.length;
	foreach (it ; 0 .. toGet) {
	    final switch (info.params [it].size.id) {
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.ULONG.id: nbUlong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.UINT.id: nbUint ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.USHORT.id: nbUshort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.UBYTE.id: nbUbyte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }	    
	}

	size = new LBinop (ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble),
			   size, Tokens.PLUS);

	if (toGet == nb && nb < info.params.length) {
	    done = true;
	    inst += new LRegRead (null, size, retSize);
	} else {
	    nb -= toGet;
	    inst += size;
	}
	return inst;
    }
    
    static LInstList GetAttrib (InfoType ret, Expression left, Expression) {
	if (COMPILER.isToLint) {
	    auto _ref = cast (RefInfo) (left.info.type);
	    auto type = cast (StructInfo) (left.info.type);
	    if (_ref) {
		type = cast (StructInfo) _ref.content;
	    }
	    bool done = false; ulong nb = ret.toGet;
	    return GetAttribFromAncestor (done, type, nb, ret.size);
	} else {
	    auto lexp = DVisitor.visitExpressionOutSide (left);
	    auto attrib = (cast (StructInfo) left.info.type).attribs [ret.toGet];
	    return new DDot (lexp, new DVar (attrib));
	}
    }
    
    static LInstList Attrib (LInstList sizeInst, LInstList left) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = left.getFirst ();
	    auto size = cast (LRegRead) sizeInst.getFirst ();
	    inst += left;	
	    inst += new LRegRead (leftExp, size.begin, size.size);
	    return inst;
	} else {
	    return sizeInst;
	}
    }

    static LInstList GetMethodFromAncestor (ref bool done, StructInfo info, ref ulong nb, LSize retSize) {	
	LInstList inst;
	LExp size;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	if (info.ancestor) {
	    inst = GetMethodFromAncestor (done, info.ancestor, nb, retSize);
	    if (done) return inst;
	    size = inst.getFirst ();
	} else {
	    inst = new LInstList;
	    size = new LConstDecimal(0, LSize.LONG);
	}
	
	auto toGet = nb < info.nbMethods ? nb : info.nbMethods;
	nbUlong += toGet;       	
	if (toGet == nb && toGet < info.nbMethods) {
	    size = new LBinop (ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble),
			       size, Tokens.PLUS);
	    done = true;
	    inst += new LRegRead (null, size, retSize);
	} else {
	    foreach (it ; 0 .. info.params.length) {
		final switch (info.params [it].size.id) {
		case LSize.LONG.id: nbLong ++; break;
		case LSize.ULONG.id: nbUlong ++; break;
		case LSize.INT.id: nbInt ++; break;
		case LSize.UINT.id: nbUint ++; break;
		case LSize.SHORT.id: nbShort ++; break;
		case LSize.USHORT.id: nbUshort ++; break;
		case LSize.BYTE.id: nbByte ++; break;
		case LSize.UBYTE.id: nbUbyte ++; break;
		case LSize.FLOAT.id: nbFloat ++; break;
		case LSize.DOUBLE.id: nbDouble ++; break;
		}	   
	    }
	    size = new LBinop (ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble),
			       size, Tokens.PLUS);
	    nb -= toGet;
	    inst += size;
	}
	return inst;	
    }
    
    static LInstList GetMethod (InfoType ret, Expression left, Expression) {
	auto _ref = cast (RefInfo) (left.info.type);
	auto type = cast (StructInfo) (left.info.type);
	if (_ref) type = cast (StructInfo) _ref.content;
	bool done = false; ulong nb = ret.toGet;
	return GetMethodFromAncestor (done, type, nb, ret.size);		
    }

    static LInstList Method (LInstList sizeInst, LInstList left) {
	auto inst = new LInstList;
	auto leftExp = left.getFirst;
	auto size = cast (LRegRead) sizeInst.getFirst;
	inst += left;
	inst += new LRegRead (leftExp, size.begin, size.size);
	return inst;
    }
        
    static LInstList InstEqual (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	    auto inst = new LInstList;
	    inst += llist + rlist;
	    inst += new LBinop (leftExp, rightExp, Tokens.DEQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Keys.IS);
	}
    }
    
    static LInstList InstNotEqual (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	    auto inst = new LInstList;
	    inst += llist + rlist;
	    inst += new LBinop (leftExp, rightExp, Tokens.NOT_EQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Keys.NOT_IS);
	}	
    }

    static LInstList InstAddr (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto leftExp = llist.getFirst ();
	    llist += new LAddr (leftExp);
	    return llist;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.AND);
	}
    }
    
    static LInstList GetTupleOfFromAncestor (StructInfo info) {
	LExp size;
	if (info.ancestor) {
	    auto inst = GetTupleOfFromAncestor (info.ancestor);
	    size = inst.getFirst ();
	} else {
	    size = new LConstDecimal (0, LSize.LONG);
	}
	
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;

	nbUlong += info.nbMethods;	
	foreach (it ; 0 .. info.params.length) {
	    final switch (info.params [it].size.id) {
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.ULONG.id: nbUlong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.UINT.id: nbUint ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.USHORT.id: nbUshort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.UBYTE.id: nbUbyte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }	   
	}
	  
	return new LInstList (new LBinop (ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble),
					  size, Tokens.PLUS));
    }

    static LInstList GetTupleOf (InfoType ret, Expression left, Expression) {
	auto _ref = cast (RefInfo) (left.info.type);
	auto type = cast (StructInfo) (left.info.type);
	if (_ref) type = cast (StructInfo) _ref.content;
	auto inst = new LInstList;

	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	LExp size;
	nbUlong += type.nbMethods;
	if (type.ancestor) {
	    auto aux = GetTupleOfFromAncestor (type.ancestor);
	    size = new LBinop (ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble),
			       aux.getFirst (), Tokens.PLUS);
	} else {
	    size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	}
	
	auto llist = LVisitor.visitExpressionOutSide (left);
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, size, Tokens.PLUS);
	return inst;		
    }
    
    static LInstList InstTupleOf (LInstList llist, LInstList list) {
	return llist;
    }

    static LInstList InstPtr (LInstList, LInstList list) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = list.getFirst ();
	    inst += list;
	    inst += new LBinop (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT, LSize.LONG), Tokens.PLUS);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) list, Tokens.AND);
	}
    }
    
    static LInstList GetSizeOf (InfoType, Expression left, Expression) {
	auto type = cast (StructInfo) left.info.type;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	foreach (it ; type.params) {
	    final switch (it.size.id) {
	    case LSize.ULONG.id: nbUlong ++; break;
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.UINT.id: nbUint ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.USHORT.id: nbUshort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.UBYTE.id: nbUbyte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }		
	}
	auto size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	auto list = new LInstList (size);
	return list;
    }

    static LInstList SizeOf (LInstList left, LInstList) {
	return left;
    }


    static LInstList InstGetSuper (LInstList, LInstList left) {
	return left;
    }


}
