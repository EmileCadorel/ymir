module semantic.types.StructUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LSize;
import lint.LConst, ast.Constante, syntax.Word;
import lint.LVisitor, semantic.types.InfoType;
import ast.Expression, lint.LFrame, semantic.types.ClassUtils;
import lint.LCall, lint.LAddr, semantic.types.StructInfo;
import semantic.types.UndefInfo, ast.Var, semantic.pack.Symbol;

class StructUtils {
    
    static string __CstName__ = "_YPCstStruct";
    static string __DstName__ = "_YPDstStruct";


    static LBinop addAllSize (ulong nbLong, ulong nbUlong, ulong nbInt, ulong nbUint, ulong nbShort, ulong nbUshort, ulong nbByte, ulong nbUbyte, ulong nbFloat, ulong nbDouble) {
	return new LBinop (new LConstDecimal (nbLong, LSize.INT, LSize.LONG),
			   new LBinop (new LConstDecimal (nbUlong, LSize.INT, LSize.ULONG),
				       new LBinop (new LConstDecimal (nbInt, LSize.INT, LSize.INT),
						   new LBinop (new LConstDecimal (nbUint, LSize.INT, LSize.UINT),
							       new LBinop (new LConstDecimal (nbShort, LSize.INT, LSize.SHORT),
									   new LBinop (new LConstDecimal (nbUshort, LSize.INT, LSize.USHORT),
										       new LBinop (new LConstDecimal (nbByte, LSize.INT, LSize.BYTE),
												   new LBinop (new LConstDecimal (nbUbyte, LSize.INT, LSize.UBYTE),
													       new LBinop (new LConstDecimal (nbFloat, LSize.INT, LSize.FLOAT),
													       	   	   new LConstDecimal (nbDouble, LSize.INT, LSize.DOUBLE),
															   Tokens.PLUS),
													       Tokens.PLUS),
												   Tokens.PLUS),
										       Tokens.PLUS),
									   Tokens.PLUS),
							       Tokens.PLUS),
						   Tokens.PLUS),
				       Tokens.PLUS),
			   Tokens.PLUS);			   
    }

    
    static void createCstStruct (string name, Array!InfoType params) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	Array!LReg regs;
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	auto interne = new LInstList;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	auto size = addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);

	Word aff = Word.eof;
	aff.str = Tokens.EQUAL.descr;
	auto var = new Var (aff);
	var.info = new Symbol (false, aff, new UndefInfo);
	foreach (it ; params) {
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
	    } else assert (false, typeid (it).toString);
	    
	    size = addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	}
	
						 
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG),
				   new LConstDecimal (1, LSize.LONG));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG), new LConstFunc (__DstName__ ~ name));
	entry.insts += interne;
	auto fr = new LFrame (__CstName__ ~ name, entry, end, retReg, regs);
	fr.isStd = false;
	LFrame.preCompiled [__CstName__ ~ name] = fr;	
	LReg.lastId = last;
    }

    static void createDstStruct (string name, Array!InfoType params) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	auto size = addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);

	foreach (it ; params) {
	    final switch (it.size.id) {
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

	    if (it.isDestructible) {
		entry.insts += new LCall (ClassUtils.__DstName__,
					  make!(Array!LExp) ([new LBinop (addr, size, Tokens.PLUS)]), LSize.NONE);
	    }
	    
	    size = addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);	    
	}
	entry.insts += new LSysCall ("free", make!(Array!LExp) ([addr]), null);
	auto fr = new LFrame (__DstName__ ~ name, entry, end, null, make!(Array!LReg) ([addr]));
	fr.isStd = false;
	LFrame.preCompiled [__DstName__ ~ name] = fr;
	LReg.lastId = last;	     
    }
    
    static LInstList InstCreateCst (bool _extern) (InfoType _type, Expression, Expression) {
	auto type = cast (StructInfo) _type;
	if (!_extern) {
	    auto it = (__CstName__ ~ type.name) in LFrame.preCompiled;
	    if (it is null) createCstStruct (type.name, type.params);
	    it = (__DstName__ ~ type.name) in LFrame.preCompiled;
	    if (it is null) createDstStruct (type.name, type.params);
	}
	auto inst = new LInstList ();
	inst += new LConstFunc (__CstName__ ~ type.name);
	return inst;
    }

    static LInstList InstCall (LInstList llist, Array!LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	Array!LExp params;
	inst += llist;
	foreach (it ; rlist) {
	    params.insertBack (it.getFirst ());
	    inst += it;
	}
	inst += new LCall ((cast (LConstFunc) leftExp).name, params, LSize.LONG);
	return inst;
    }

    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }    
    
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

    static LInstList InstAffectNull (LInstList llist, LInstList) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, new LConstDecimal (0, LSize.LONG));
	return inst;
    }    

    
    static LInstList InstDestruct (LInstList llist) {
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (expr)]), LSize.NONE);
	return inst;
    }
       
    static LInstList GetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    static LInstList StringOf (LInstList, LInstList left) {
	return left;
    }

    static LInstList Init (LInstList, LInstList) {
	return new LInstList (new LConstDecimal (0, LSize.LONG));
    }

    static LInstList GetAttrib (InfoType ret, Expression left, Expression) {
	auto type = cast (StructInfo) (left.info.type);	
	auto inst = new LInstList;

	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	foreach (it ; 0 .. ret.toGet) {	    
	    final switch (type.params [it].size.id) {
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

	auto size = addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	auto l = LVisitor.visitExpressionOutSide (left);
	auto leftExp = l.getFirst ();
	inst += l;
	inst += new LRegRead (leftExp, size, ret.size);
	return inst;
    }

    static LInstList Attrib (LInstList, LInstList left) {
	return left;
    }

    static LInstList InstEqual (LInstList llist, LInstList rlist) {
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	auto inst = new LInstList;
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.DEQUAL);
	return inst;
    }
    
    static LInstList InstNotEqual (LInstList llist, LInstList rlist) {
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	auto inst = new LInstList;
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.NOT_EQUAL);
	return inst;
    }

    static LInstList InstAddr (LInstList llist) {
	auto leftExp = llist.getFirst ();
	llist += new LAddr (leftExp);
	return llist;
    }


    static LInstList InstNbRef (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LRegRead (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT), LSize.LONG);
	return inst;
    }

    static LInstList InstTupleOf (LInstList, LInstList list) {
	return list;
    }

    static LInstList InstPtr (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LBinop (cast (LExp) leftExp, new LConstDecimal (2, LSize.INT, LSize.LONG), Tokens.PLUS);
	return inst;
    }
    
    
}
