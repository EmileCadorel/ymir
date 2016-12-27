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
    
    static void createCstStruct (string name, Array!InfoType params) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	Array!LReg regs;
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	auto interne = new LInstList;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble;
	auto size = new LBinop (new LConstDWord (nbLong + 2, LSize.LONG),
				new LBinop (new LConstDWord (nbInt, LSize.INT),
					    new LBinop (new LConstDWord (nbShort, LSize.SHORT),
							new LBinop (new LConstDWord (nbByte, LSize.BYTE),
								    new LBinop (new LConstDWord (nbFloat, LSize.FLOAT),
										new LConstDWord (nbDouble, LSize.DOUBLE),
										Tokens.PLUS),
								    Tokens.PLUS),
							Tokens.PLUS),
					    Tokens.PLUS),
				Tokens.PLUS);

	Word aff = Word.eof;
	aff.str = Tokens.EQUAL.descr;
	auto var = new Var (aff);
	var.info = new Symbol (false, aff, new UndefInfo);
	foreach (it ; params) {
	    final switch (it.size.id) {
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }
	    
	    regs.insertBack (new LReg (it.size));
	    auto type = it.BinaryOpRight (aff, var);
	    if (type !is null) {
		LInstList rlist = new LInstList (regs.back ());
		LInstList llist = new LInstList (new LRegRead (retReg, size, it.size));
		interne += type.lintInst (llist, rlist);
	    }
	    	    
	    size = new LBinop (new LConstDWord (nbLong + 2, LSize.LONG),
				    new LBinop (new LConstDWord (nbInt, LSize.INT),
						new LBinop (new LConstDWord (nbShort, LSize.SHORT),
							    new LBinop (new LConstDWord (nbByte, LSize.BYTE),
									new LBinop (new LConstDWord (nbFloat, LSize.FLOAT),
										    new LConstDWord (nbDouble, LSize.DOUBLE),
										    Tokens.PLUS),
									Tokens.PLUS),
							    Tokens.PLUS),
						Tokens.PLUS),
				    Tokens.PLUS);	    
	}
	
						 
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (0), LSize.LONG),
				   new LConstQWord (1));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDWord (1, LSize.LONG), LSize.LONG), new LConstFunc (__DstName__ ~ name));
	entry.insts += interne;
	auto fr = new LFrame (__CstName__ ~ name, entry, end, retReg, regs);
	LFrame.preCompiled [__CstName__ ~ name] = fr;	
	LReg.lastId = last;
    }

    static void createDstStruct (string name, Array!InfoType params) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble;
	auto size = new LBinop (new LConstDWord (nbLong + 2, LSize.LONG),
				new LBinop (new LConstDWord (nbInt, LSize.INT),
					    new LBinop (new LConstDWord (nbShort, LSize.SHORT),
							new LBinop (new LConstDWord (nbByte, LSize.BYTE),
								    new LBinop (new LConstDWord (nbFloat, LSize.FLOAT),
										new LConstDWord (nbDouble, LSize.DOUBLE),
										Tokens.PLUS),
								    Tokens.PLUS),
							Tokens.PLUS),
					    Tokens.PLUS),
				Tokens.PLUS);


	foreach (it ; params) {
	    final switch (it.size.id) {
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }

	    if (it.isDestructible) {
		entry.insts += new LCall (ClassUtils.__DstName__,
					  make!(Array!LExp) ([new LBinop (addr, size, Tokens.PLUS)]), LSize.NONE);
	    }

	    size = new LBinop (new LConstDWord (nbLong + 2, LSize.LONG),
			       new LBinop (new LConstDWord (nbInt, LSize.INT),
					   new LBinop (new LConstDWord (nbShort, LSize.SHORT),
						       new LBinop (new LConstDWord (nbByte, LSize.BYTE),
								   new LBinop (new LConstDWord (nbFloat, LSize.FLOAT),
									       new LConstDWord (nbDouble, LSize.DOUBLE),
									       Tokens.PLUS),
								   Tokens.PLUS),
						       Tokens.PLUS),
					   Tokens.PLUS),
			       Tokens.PLUS);
	    
	}
	entry.insts += new LSysCall ("free", make!(Array!LExp) ([addr]), null);
	auto fr = new LFrame (__DstName__ ~ name, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__DstName__ ~ name] = fr;
	LReg.lastId = last;	     
    }
    
    static LInstList InstCreateCst (InfoType _type, Expression, Expression) {
	auto type = cast (StructInfo) _type;
	auto it = (__CstName__ ~ type.name) in LFrame.preCompiled;
	if (it is null) createCstStruct (type.name, type.params);
	it = (__DstName__ ~ type.name) in LFrame.preCompiled;
	if (it is null) createDstStruct (type.name, type.params);
	auto inst = new LInstList ();
	inst += new LConstFunc (__CstName__ ~ type.name);
	return inst;
    }

    static LInstList InstCall (LInstList llist, Array!LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	Array!LExp params;
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
	return new LInstList (new LConstQWord (0));
    }

    static LInstList GetAttrib (InfoType ret, Expression left, Expression) {
	auto type = cast (StructInfo) (left.info.type);
	auto inst = new LInstList;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble;
	auto size = new LBinop (new LConstDWord (nbLong + 2, LSize.LONG),
				new LBinop (new LConstDWord (nbInt, LSize.INT),
					    new LBinop (new LConstDWord (nbShort, LSize.SHORT),
							new LBinop (new LConstDWord (nbByte, LSize.BYTE),
								    new LBinop (new LConstDWord (nbFloat, LSize.FLOAT),
										new LConstDWord (nbDouble, LSize.DOUBLE),
										Tokens.PLUS),
								    Tokens.PLUS),
							Tokens.PLUS),
					    Tokens.PLUS),
				Tokens.PLUS);

	foreach (it ; 0 .. ret.toGet) {	    
	    final switch (type.params [it].size.id) {
	    case LSize.LONG.id: nbLong ++; break;
	    case LSize.INT.id: nbInt ++; break;
	    case LSize.SHORT.id: nbShort ++; break;
	    case LSize.BYTE.id: nbByte ++; break;
	    case LSize.FLOAT.id: nbFloat ++; break;
	    case LSize.DOUBLE.id: nbDouble ++; break;
	    }

	    size = new LBinop (new LConstDWord (nbLong + 2, LSize.LONG),
			       new LBinop (new LConstDWord (nbInt, LSize.INT),
					   new LBinop (new LConstDWord (nbShort, LSize.SHORT),
						       new LBinop (new LConstDWord (nbByte, LSize.BYTE),
								   new LBinop (new LConstDWord (nbFloat, LSize.FLOAT),
									       new LConstDWord (nbDouble, LSize.DOUBLE),
									       Tokens.PLUS),
								   Tokens.PLUS),
						       Tokens.PLUS),
					   Tokens.PLUS),
			       Tokens.PLUS);
	    
	}

	auto l = LVisitor.visitExpressionOutSide (left);
	auto leftExp = l.getFirst ();
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

    
}
