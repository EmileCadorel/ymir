module semantic.types.FloatUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, lint.LExp, lint.LReg, lint.LCast;
import syntax.Tokens, lint.LSize;
import syntax.Word, ast.Constante;
import semantic.types.InfoType, lint.LConst;
import lint.LVisitor, lint.LUnop;

/**
 Cette classe regroupe les fonctions nécéssaire à la transformation d'un float en lint.
 */
class FloatUtils {

    /**
     Affectation entre deux float.
     Params:
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }
    
    /**
     Affectation entre un float et un int.
     Params:
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstAffectInt (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, new LCast (rightExp, LSize.DOUBLE)));
	return inst;
    }

    /**
     Operateur entre deux float.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }
    
    /**
     Operateur entre un float et un int.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), op));
	return inst;
    }

    /**
     Operateur entre un int et un float.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.DOUBLE), rightExp, op));
	return inst;
    }

    /**
     Operateur d'affectation entre 2 float
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, leftExp, op));
	return inst;
    }
    
    /**
     Operateur d'affectation entre un float et un int
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpAffInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), leftExp, op));
	return inst;
    }
    
    /**
     Operateur de test entre deux float.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    /**
     Operateur de test entre un float et un int.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpTestInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), op));
	return inst;
    }

    /**
     Operateur de test entre un int et un float.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.DOUBLE), rightExp, op));
	return inst;
    }
   
    /**
     Operateur de cast vers un long
     Params:
     llist = les instructions de l'operande.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstCastFloat (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LCast (leftExp, LSize.DOUBLE);
	return inst;
    }

    /**
     Operateur de cast vers un long
     Params:
     llist = les instructions de l'operande.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstCastDec (DecimalConst size) (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LCast (leftExp, fromDecimalConst (size));
	return inst;
    }

    
    /**
     La constante d'init d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList FloatInit (LInstList, LInstList) {
	return new LInstList (new LConstFloat (0.0f));
    }

    /**
     La constante max d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Max (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.max));
    }

    /**
     La constante min d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Min (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.min_normal));
    }

    /**
     La constante Nan d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Nan (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.nan));
    }

    /**
     La constante dig d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Dig (LInstList, LInstList) {
	return new LInstList (new LConstDecimal (float.dig, LSize.INT));
    }

    /**
     La constante epsilon d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Epsilon (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.epsilon));
    }

    /**
     La constante mant_dig d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList MantDig (LInstList, LInstList) {
	return new LInstList (new LConstDecimal (float.mant_dig, LSize.INT));
    }

    /**
     La constante max_10_exp d'un float.
     Returns: la liste d'instruction du lint.
    */
    static LInstList Max10Exp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.max_10_exp));
    }

    /**
     La constante max_exp d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList MaxExp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.max_exp));
    }

    /**
     La constante min_10_exp d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Min10Exp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.min_10_exp));
    }

    /**
     La constante min_exp d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList MinExp (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.min_exp));
    }

    /**
     La constante infinity d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Inf (LInstList, LInstList) {
	return new LInstList (new LConstFloat (float.infinity));
    }

    /**
     Operateur '-' sur un float.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstInv (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst;
	inst += llist;
	inst += new LBinop (new LConstDouble (0), leftExp, Tokens.MINUS);
	return inst;
    }

    /**
     Operateur sqrt sur un float.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Sqrt (LInstList, LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LUnop (left, Tokens.SQRT);
	return inst;
    }

    /**
     Constante de nom du type float.
     Params:
     left = l'expression de type float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList FloatGetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    /**
     Constante de nom du type float (nécessite FloatGetStringOf au préalable).
     Params:
     left = la liste d'instruction de l'operande.
     Returns: la liste d'instruction du lint.
     */
    static LInstList FloatStringOf (LInstList, LInstList left) {
	return left;
    }

    
}
