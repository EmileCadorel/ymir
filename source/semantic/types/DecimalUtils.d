module semantic.types.DecimalUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens, lint.LCast;
import lint.LUnop, lint.LAddr;
import lint.LConst, lint.LSize;
import ast.Constante, lint.LVisitor, syntax.Word;
import semantic.types.InfoType, ast.Var;


class DecimalUtils {


    /**
     Affectation entre deux int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
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
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, leftExp, op));
	return inst;
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
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
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
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op, LSize.UBYTE));
	return inst;
    }
    
    static LInstList InstCast (DecimalConst size) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, fromDecimalConst (size));
	return inst;
    }
   
    /**
     Operateur unaire d'un int.
     Params:
     op = l'operateur.
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstUnop (Tokens op) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LUnop (left, op);
	return inst;
    }
    
    /**
     La constante init du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList Init (DecimalConst size) (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (0, fromDecimalConst (size));
	return inst;
    }
    
    /**
     La constante max du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList Max (DecimalConst size) (LInstList, LInstList) {
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
    }
    
    /**
     La constante min du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList Min (DecimalConst size) (LInstList, LInstList) {
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
    }
    
    /**
     La constante de taille du int.
     Returns: une liste d'instruction du lint.
    */
    static LInstList SizeOf (DecimalConst size) (LInstList, LInstList) {
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
    }    
    
    /**
     Instruction de cast en char d'un int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstCastChar (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.BYTE);
	return inst;
    }    
    
    /**
     Instruction de cast en bool d'un int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstCastBool (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.BYTE);
	return inst;
    }

    /**
     Instruction de cast en float d'un int.
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     Returns: une liste d'instruction du cast.
     */
    static LInstList InstCastFloat (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.DOUBLE);
	return inst;
    }

    /**
     L'instruction de récuperation de l'adresse d'un int.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
    */
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList ();
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }
    
    /**
     Operateur '++'
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
    */
    static LInstList InstPplus (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LUnop (exp, Tokens.DPLUS, true);
	return inst;
    }

    /**
     Operateur '--'
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
    */
    static LInstList InstSsub (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LUnop (exp, Tokens.DMINUS, true);
	return inst;
    }

    /**
     Operateur '^^='
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.     
     */
    static LInstList InstDXorAff (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXorAff int");
    }

    /**
     Operateur '^^'
     Params:
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: une liste d'instruction du lint.     
     */
    static LInstList InstDXor (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }
    
  
}
