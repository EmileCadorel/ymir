module semantic.types.LongUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens;
import lint.LSysCall, std.container, lint.LExp, lint.LConst;
import lint.LCast, lint.LUnop, semantic.types.IntInfo;
import lint.LAddr, lint.LSize, lint.LVisitor;
import syntax.Word, ast.Constante;
import semantic.types.InfoType, semantic.types.LongInfo;

/**
 Cette classe regroupe les fonctions de transformation de long en lint.
 */
class LongUtils {

    /**
     Operateur d'affectation.
     Params: 
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }
    
    /**
     Operateur d'affectation entre un long et un int.
     Params: 
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstAffectInt (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, new LCast (rightExp, LSize.LONG)));
	return inst;
    }
    
    /**
     Operateur binaire entre deux long.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    /**
     Operateur binaire entre un long et un int.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.LONG), op));
	return inst;
    }

    /**
     Operateur binaire entre un int et un long.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.LONG), rightExp, op));
	return inst;
    }

    /**
     Operateur binaire d'affectation entre deux long.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, leftExp, op));
	return inst;
    }
    
    /**
     Operateur binaire d'affectation entre un long et un int.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpAffInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.LONG), leftExp, op));
	return inst;
    }

    /**
     Operateur binaire de test entre deux long.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    
    /**
     Operateur binaire de test entre un long et un int.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpTestInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.LONG), op));
	return inst;
    }

    /**
     Operateur binaire de test entre un int et un long.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */    
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.LONG), rightExp, op));
	return inst;
    }

    /**
     Operateur de cast d'un long en char.
     Params: 
     llist = les instructions de l'operande.
     Returns: les instructions du lint.
     */    
    static LInstList InstCastChar (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.BYTE);
	return inst;
    }
    
    /**
     Operateur de cast d'un long en bool.
     Params: 
     llist = les instructions de l'operande.
     Returns: les instructions du lint.
     */    
    static LInstList InstCastBool (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.BYTE);
	return inst;
    }

    /**
     Operateur de cast d'un long en int.
     Params: 
     llist = les instructions de l'operande.
     Returns: les instructions du lint.
     */    
    static LInstList InstCastInt (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.INT);
	return inst;
    }
    
    /**
     Operateur de cast en long.
     Params: 
     llist = les instructions de l'operande.
     Returns: les instructions du lint.
     */    
    static LInstList InstCastLong (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.LONG);
	return inst;
    }

    /**
     Operateur unaire d'un long.
     Params: 
     op = l'operateur.
     llist = les instructions de l'operande.
     Returns: les instructions du lint.
     */    
    static LInstList InstUnop (Tokens op) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LUnop (left, op);
	return inst;
    }
    
    /**
     Constante init d'un long.
     Returns: les instructions du lint.
     */    
    static LInstList IntInit (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (0, LSize.LONG);
	return inst;
    }

    /**
     Constante max d'un long.
     Returns: les instructions du lint.
     */    
    static LInstList IntMax (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (long.max, LSize.LONG);
	return inst;
    }
    
    /**
     Constante min d'un long.
     Returns: les instructions du lint.
     */    
    static LInstList IntMin (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (long.min, LSize.LONG);
	return inst;
    }

    /**
     Constante de taille d'un long.
     Returns: les instructions du lint.
     */        
    static LInstList IntSizeOf (LInstList, LInstList) {
	auto inst = new LInstList ();
	inst += new LConstDecimal (1, LSize.INT, LongInfo.sizeOf);
	return inst;
    }    

    /**
     Operateur d'addresse d'un long.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: les instructions du lint.
    */        
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList ();
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }
    
    /**
     Operateur unaire '++'
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: les instructions du lint.
    */        
    static LInstList InstPplus (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LUnop (exp, Tokens.DPLUS, true);
	return inst;
    }

    /**
     Operateur unaire '--'
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: les instructions du lint.
    */        
    static LInstList InstSsub (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LUnop (exp, Tokens.DMINUS, true);
	return inst;
    }

    /**
     Constante de nom du type long.
     Params:
     left = l'expression de type long.
     Returns: la liste d'instruction lint.
     */
    static LInstList GetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    /**
     Constante de nom du type long (necessite GetStringOf au préalable).
     Params:
     left = l'expression de type long.
     Returns: la liste d'instruction lint.
     */
    static LInstList StringOf (LInstList, LInstList left) {
	return left;
    }


    /**
     Operateur '^^='.
     Bugs: TODO
     */
    static LInstList InstDXorAff (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXorAff long");
    }

    /**
     Operateur '^^=' avec un int.
     Bugs: TODO
     */
    static LInstList InstDXorAffInt (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXorAff long");
    }

    /**
     Operateur '^^'.
     Bugs: TODO
     */
    static LInstList InstDXor (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }

    /**
     Operateur '^^' avec un int.
     Bugs: TODO
     */
    static LInstList InstDXorInt (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }

    /**
     Operateur '^^' avec un int à gauche.
     Bugs: TODO
    */
    static LInstList InstDXorIntRight (LInstList llist, LInstList rlist) {
	assert (false, "TODO, DXor int");
    }

    
}
