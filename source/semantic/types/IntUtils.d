module semantic.types.IntUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens;
import lint.LSysCall, std.container, lint.LExp, lint.LConst;
import lint.LCast, lint.LUnop, semantic.types.IntInfo;
import lint.LAddr, lint.LSize, lint.LVisitor;
import syntax.Word, ast.Constante;

/**
 Cette classe regroupe un ensemble de fonction nécéssaire pour la transformation en lint.
 */
class IntUtils {

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
	inst += (new LBinop (leftExp, rightExp, op));
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
    static LInstList IntInit (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (0, LSize.INT);
	return inst;
    }

    /**
     La constante max du int.
     Returns: une liste d'instruction du lint.
     */
    static LInstList IntMax (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (int.max, LSize.INT);
	return inst;
    }
    
    /**
     La constante min du int.
     Returns: une liste d'instruction du lint.
     */
    static LInstList IntMin (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (int.min, LSize.INT);
	return inst;
    }

    /**
     La constante de taille du int.
     Returns: une liste d'instruction du lint.
     */
    static LInstList IntSizeOf (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (1, LSize.INT, IntInfo.sizeOf);
	return inst;
    }    

    /**
     La constante de nom du int.
     Returns: une liste d'instruction du lint.
     */
    static LInstList IntStringOf (LInstList, LInstList) {
	auto inst = new LInstList;
	auto str = new String (Word.eof, "int").expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    /**
     La constante de nom du int constant.
     Returns: une liste d'instruction du lint.
     */
    static LInstList IntStringOfConst (LInstList, LInstList) {
	auto inst = new LInstList;
	auto str = new String (Word.eof, "const (int)").expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
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
