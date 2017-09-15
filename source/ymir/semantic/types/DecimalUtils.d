module ymir.semantic.types.DecimalUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.dtarget._;
import ymir.compiler.Compiler;

class DecimalUtils {


    /**
     Affectation entre deux int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LWrite (leftExp, rightExp));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.EQUAL);
	}
    }    
    
    /**
     Operateur d'affectation entre deux int.
     Example:
     ----
     a += b;
     ----
     Params:
     op = l'operateur.
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, rightExp, leftExp, op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DBinary (cast (DExpression) llist, cast (DExpression) rlist, op), Tokens.EQUAL);
	}
    }


    /**
     Operateur binaire entre deux int.
     Params:
     op = l'operateur.
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, rightExp, op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, op);
	}
    }
    
    /**
     Operateur de test entre deux int.
     Params:
     op = l'operateur.
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, rightExp, op, LSize.UBYTE));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, op);
	}
    }
    
    static LInstList InstCast (DecimalConst size) (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto left = llist.getFirst;
	    inst += llist;
	    inst += new LCast (left, fromDecimalConst (size));
	    return inst;
	} else {
	    return new DCast (new DType (fromDecimalConst (size)), cast (DExpression) llist);
	}
    }
   
    /**
     Operateur unaire d'un int.
     Params:
     op = l'operateur.
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstUnop (Tokens op) (LInstList llist) {
	if (COMPILER.isToLint) { 
	    auto inst = new LInstList;
	    auto left = llist.getFirst ();
	    inst += llist;
	    inst += new LUnop (left, op);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, op);
	}
    }
    
    /**
     La constante init du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList Init (DecimalConst size) (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList ();
	    inst += new LConstDecimal (0, fromDecimalConst (size));
	    return inst;
	} else {
	    return new DCast (new DType (fromDecimalConst (size)), new DDecimal (0));
	}
    }
    
    /**
     La constante max du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList Max (DecimalConst size) (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList ();
	    final switch (size.id) {
	    case DecimalConst.BYTE.id :  inst += new LConstDecimal (byte.max, LSize.BYTE); break;
	    case DecimalConst.UBYTE.id :  inst += new LConstDecimal (ubyte.max, LSize.UBYTE); break;
	    case DecimalConst.SHORT.id :  inst += new LConstDecimal (short.max, LSize.SHORT); break;
	    case DecimalConst.USHORT.id :  inst += new LConstDecimal (ushort.max, LSize.USHORT); break;
	    case DecimalConst.INT.id :  inst += new LConstDecimal (int.max, LSize.INT); break;
	    case DecimalConst.UINT.id :  inst += new LConstDecimal (uint.max, LSize.UINT); break;
	    case DecimalConst.LONG.id :  inst += new LConstDecimal (long.max, LSize.LONG); break;
	    case DecimalConst.ULONG.id :  inst += new LConstDecimal (-1, LSize.ULONG); break;
	    }	
	    return inst;
	} else {
	    final switch (size.id) {
	    case DecimalConst.BYTE.id :  return new DCast (new DType (Dlang.BYTE),  new DDecimal (byte.max));
	    case DecimalConst.UBYTE.id :  return new DCast (new DType (Dlang.UBYTE),  new DDecimal (ubyte.max));
	    case DecimalConst.SHORT.id :  return new DCast (new DType (Dlang.SHORT),  new DDecimal (short.max));
	    case DecimalConst.USHORT.id :  return new DCast (new DType (Dlang.USHORT),  new DDecimal (ushort.max));
	    case DecimalConst.INT.id :  return new DCast (new DType (Dlang.INT),  new DDecimal (int.max));
	    case DecimalConst.UINT.id :  return new DCast (new DType (Dlang.UINT),  new DDecimal (uint.max));
	    case DecimalConst.LONG.id :  return new DCast (new DType (Dlang.LONG),  new DDecimal (long.max));
	    case DecimalConst.ULONG.id :  return new DCast (new DType (Dlang.ULONG),  new DDecimal (ulong.max));
	    }	
	}
    }
    
    /**
     La constante min du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList Min (DecimalConst size) (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList ();
	    final switch (size.id) {
	    case DecimalConst.BYTE.id :  inst += new LConstDecimal (byte.min, LSize.BYTE); break;
	    case DecimalConst.UBYTE.id :  inst += new LConstDecimal (ubyte.min, LSize.UBYTE); break;
	    case DecimalConst.SHORT.id :  inst += new LConstDecimal (short.min, LSize.SHORT); break;
	    case DecimalConst.USHORT.id :  inst += new LConstDecimal (ushort.min, LSize.USHORT); break;
	    case DecimalConst.INT.id :  inst += new LConstDecimal (int.min, LSize.INT); break;
	    case DecimalConst.UINT.id :  inst += new LConstDecimal (uint.min, LSize.UINT); break;
	    case DecimalConst.LONG.id :  inst += new LConstDecimal (long.min, LSize.LONG); break;
	    case DecimalConst.ULONG.id :  inst += new LConstDecimal (ulong.min, LSize.ULONG); break;
	    }
	    return inst;
	} else {

	    final switch (size.id) {
	    case DecimalConst.BYTE.id :  return new DCast (new DType (Dlang.BYTE),  new DDecimal (byte.min));
	    case DecimalConst.UBYTE.id :  return new DCast (new DType (Dlang.UBYTE),  new DDecimal (ubyte.min));
	    case DecimalConst.SHORT.id :  return new DCast (new DType (Dlang.SHORT),  new DDecimal (short.min));
	    case DecimalConst.USHORT.id :  return new DCast (new DType (Dlang.USHORT),  new DDecimal (ushort.min));
	    case DecimalConst.INT.id :  return new DCast (new DType (Dlang.INT),  new DDecimal (int.min));
	    case DecimalConst.UINT.id :  return new DCast (new DType (Dlang.UINT),  new DDecimal (uint.min));
	    case DecimalConst.LONG.id :  return new DCast (new DType (Dlang.LONG),  new DDecimal (long.min));
	    case DecimalConst.ULONG.id :  return new DCast (new DType (Dlang.ULONG),  new DDecimal (ulong.min));
	    }	
	}
    }

    
    /**
     La constante de taille du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList SizeOf (DecimalConst size) (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList ();
	    final switch (size.id) {
	    case DecimalConst.BYTE.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.BYTE); break;
	    case DecimalConst.UBYTE.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.UBYTE); break;
	    case DecimalConst.SHORT.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.SHORT); break;
	    case DecimalConst.USHORT.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.USHORT); break;
	    case DecimalConst.INT.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.INT); break;
	    case DecimalConst.UINT.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.UINT); break;
	    case DecimalConst.LONG.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.LONG); break;
	    case DecimalConst.ULONG.id :  inst += new LConstDecimal (1, LSize.UBYTE, LSize.ULONG); break;
	    }
	    return inst;
	} else {
	    return new DCast (new DType (Dlang.UBYTE), new DDecimal (fromDecimalConst (size)));
	}
    }    
    
    /**
     Instruction de cast en char d'un int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstCastChar (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto left = llist.getFirst;
	    inst += llist;
	    inst += new LCast (left, LSize.BYTE);
	    return inst;
	} else {
	    return new DCast (new DType (Dlang.CHAR), cast (DExpression) llist);
	}
    }    
    
    /**
     Instruction de cast en bool d'un int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstCastBool (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto left = llist.getFirst;
	    inst += llist;
	    inst += new LCast (left, LSize.BYTE);
	    return inst;
	} else {
	    return new DCast (new DType (Dlang.BOOL), cast (DExpression) llist);
	}
    }

    /**
     Instruction de cast en float d'un int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du cast.
     */
    static LInstList InstCastFloat (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto left = llist.getFirst;
	    inst += llist;
	    inst += new LCast (left, LSize.DOUBLE);
	    return inst;
	} else {
	    return new DCast (new DType (Dlang.DOUBLE), cast (DExpression) llist);
	}
    }

    /**
     L'instruction de récuperation de l'adresse d'un int.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
    */
    static LInstList InstAddr (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList ();
	    auto exp = llist.getFirst ();
	    inst += llist;
	    inst += new LAddr (exp);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.AND);
	}
    }
    
    /**
     Operateur '++'
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
    */
    static LInstList InstPplus (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto exp = llist.getFirst ();
	    inst += llist;
	    inst += new LUnop (exp, Tokens.DPLUS, true);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.DPLUS);
	}
    }

    /**
     Operateur '--'
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
    */
    static LInstList InstSsub (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto exp = llist.getFirst ();
	    inst += llist;
	    inst += new LUnop (exp, Tokens.DMINUS, true);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.DMINUS);
	}
    }

    /**
     Operateur '^^='
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.     
     */
    static LInstList InstDXorAff (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    assert (false, "TODO, DXorAff int");
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.DXOR_EQUAL);
	}
    }

    /**
     Operateur '^^'
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.     
     */
    static LInstList InstDXor (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    assert (false, "TODO, DXor int");
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.DXOR);
	}
    }
    
  
}
