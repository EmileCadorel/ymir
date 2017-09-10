module ymir.semantic.types.TupleUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;

class TupleUtils {
    
    static void createCstTuple (string name, Array!InfoType params) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	Array!LReg regs;
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	auto interne = new LInstList;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	auto size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);

	Word aff = Word.eof;
	aff.str = Tokens.EQUAL.descr;
	auto var = new Var (aff);
	var.info = new Symbol (aff, new UndefInfo);

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
	    } else if (auto str = cast (StructCstInfo) it) {
		auto rExp = regs.back ();
		auto lExp = new LRegRead (retReg, size, it.size);
		interne += new LWrite (lExp, rExp);
	    } else assert (false, typeid (it).toString);
	    
	    size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);	
	}
	
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);
	entry.insts += interne;
	
	auto fr = new LFrame (StructUtils.__CstName__ ~ name, entry, end, retReg, regs);
	fr.isStd = false;
	LFrame.preCompiled [StructUtils.__CstName__ ~ name] = fr;	
	LReg.lastId = last;
	createSimpleCstTuple (name, params);
    }

    static void createSimpleCstTuple (string name, Array!InfoType params) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	Array!LReg regs;
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	auto interne = new LInstList;
	ulong nbLong, nbInt, nbShort, nbByte, nbFloat, nbDouble, nbUlong, nbUint, nbUshort, nbUbyte;
	auto size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);

	Word aff = Word.eof;
	aff.str = Tokens.EQUAL.descr;
	auto var = new Var (aff);
	var.info = new Symbol (aff, new UndefInfo);
	
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

	    
	    auto left = (new LRegRead (retReg, size, it.size));
	    if (it.size != LSize.FLOAT && it.size != LSize.DOUBLE)
		interne += new LWrite (left, new LConstDecimal (0, it.size));
	    else
		interne += new LWrite (left, new LConstDouble (0));
	    
	    size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);	
	}
	
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);
	entry.insts += interne;
	
	auto fr = new LFrame (StructUtils.__CstNameEmpty__ ~ name, entry, end, retReg, regs);
	fr.isStd = false;
	LFrame.preCompiled [StructUtils.__CstNameEmpty__ ~ name] = fr;	
	LReg.lastId = last;
    }

    
    
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

	inst += new LWrite (leftExp, rightExp);
	return inst;

    }       

    static LInstList GetSizeOf (InfoType, Expression left, Expression) {
	auto type = cast (TupleInfo) left.info.type;
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

    static LInstList GetAttrib (InfoType ret, Expression left, Expression) {
	auto _ref = cast (RefInfo) (left.info.type);
	auto type = cast (TupleInfo) (left.info.type);
	if (_ref) {
	    type = cast (TupleInfo) _ref.content;
	}
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

	auto size = ClassUtils.addAllSize (nbLong, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	
	inst += new LRegRead (null, size, ret.size);
	return inst;
    }

    static LInstList Attrib (LInstList sizeInst, LInstList left) {
	auto inst = new LInstList;
	auto leftExp = left.getFirst ();
	auto size = cast (LRegRead) sizeInst.getFirst ();
	inst += left;
	inst += new LRegRead (leftExp, size.begin, size.size);
	return inst;
    }
    
    static LInstList SizeOf (LInstList left, LInstList) {
	return left;
    }

    static LInstList InstCreateCstEmpty (InfoType _type, Expression _tuple, Expression) {	
	string tupleName = Mangler.mangle!"tuple" (new Namespace (_tuple.token.locus.file), _type.simpleTypeString ());
	auto type = cast(TupleInfo) _type;
	auto it = (StructUtils.__CstName__ ~ tupleName) in LFrame.preCompiled;
	if (it is null) TupleUtils.createCstTuple (tupleName, type.params);
	
	return new LInstList (new LConstFunc (StructUtils.__CstNameEmpty__ ~ tupleName));
    }

    static LInstList InstCallEmpty (LInstList llist, LInstList) {
	auto inst = new LInstList ();
	auto leftExp = llist.getFirst ();
	Array!LExp params;
	inst += llist;
	inst += new LCall ((cast(LConstFunc) leftExp).name, params, LSize.LONG);
	return inst;
    }

    

}
