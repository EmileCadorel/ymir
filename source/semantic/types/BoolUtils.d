module semantic.types.BoolUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens, lint.LCast;
import semantic.types.IntInfo, lint.LUnop, lint.LAddr;
import lint.LConst, lint.LSize;
import ast.Constante, lint.LVisitor, syntax.Word;
import semantic.types.InfoType, ast.Var;

/**
 Cette classe regroupe toutes les fonctions nécéssaire à la transformation du type bool en lint.
 */
class BoolUtils {

    /**
     Affectation de deux élément de type bool.
     Params:
     llist = les instructions de l'élément de gauche
     rlist = les instructions de l'élément de droite.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }
    
    /**
     Opérateur entre deux élément de type bool.
     Params:
     op = l'operateur à appliquer
     llist = les instructions de l'élément de gauche
     rlist = les instructions de l'élément de droite.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    
    /**
     Opérateur sur un élément de type bool.
     Params:
     op = l'operateur à appliquer
     llist = les instructions de l'élément de gauche     
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstUnop (Tokens op) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LUnop (left, op);
	return inst;
    }

    /**
     Opérateur XOR sur un élément de type bool.
     Params:
     llist = les instructions de l'élément de gauche     
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstXor (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst ();
	inst += llist;
	inst += new LBinop (left, new LConstByte (1), Tokens.XOR);
	return inst;
    }

    /**
     Opérateur de cast vers un char du type bool.
     Params:
     llist = les instructions de l'élément
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstCastChar (LInstList llist) {
	return llist;
    }

    /**
     Opérateur de cast vers un int du type bool.
     Params:
     llist = les instructions de l'élément
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstCastInt (LInstList llist) {
	auto list = new LInstList;
	auto first = llist.getFirst ();
	list += llist;
	list += new LCast (first, LSize.INT);
	return list;
    }

    /**
     Opérateur de récupération de l'adresse d'un type bool.
     Params:
     llist = les instructions de l'élément
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }

    /**
     Constante d'init du type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList BoolInit (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstByte (0);
	return inst;
    }

    /**
     Constante de taille du type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList BoolSize (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstDWord (1, LSize.BYTE);
	return inst;
    }

    /**
     Constante de nom du type bool.
     Params:
     left = l'expression de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList BoolGetStringOf (InfoType, Expression left, Expression) {
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
    static LInstList BoolStringOf (LInstList, LInstList left) {
	return left;
    }

    /**
     Constante 'true' de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstTrue (LInstList, LInstList) {
	return new LInstList (new LConstByte (1));
    }
    
    /**
     Constante 'false' de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstFalse (LInstList, LInstList) {
	return new LInstList (new LConstByte (0));
    }

}
