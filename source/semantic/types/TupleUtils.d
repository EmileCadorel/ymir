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
import semantic.pack.Namespace;
import ast.Expression, utils.Mangler;
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

    static LInstList GetSizeOf (InfoType, Expression left, Expression) {
	import semantic.types.StructUtils;
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
	import semantic.types.RefInfo;
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

	auto size = ClassUtils.addAllSize (nbLong + 2, nbUlong, nbInt, nbUint, nbShort, nbUshort, nbByte, nbUbyte, nbFloat, nbDouble);
	
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
	import semantic.pack.Frame, semantic.types.StructUtils;
	
	string tupleName = Mangler.mangle!"tuple" (new Namespace (_tuple.token.locus.file), _type.simpleTypeString ());
	auto type = cast(TupleInfo) _type;
	auto it = (StructUtils.__CstName__ ~ tupleName) in LFrame.preCompiled;
	if (it is null) StructUtils.createCstStruct (tupleName, type.params);
	it = (StructUtils.__DstName__ ~ tupleName) in LFrame.preCompiled;
	if (it is null) StructUtils.createDstStruct (tupleName, type.params);
	
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
