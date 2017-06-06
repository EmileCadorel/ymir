module semantic.types.BoolUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens, lint.LCast;
import lint.LUnop, lint.LAddr;
import lint.LConst, lint.LSize;
import ast.Constante, lint.LVisitor, syntax.Word;
import semantic.types.InfoType, ast.Var;
import lint.LJump;

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
	auto lpaire = LVisitor.isInCondition ();	
	if (op.id == Tokens.DAND.id && lpaire.faux !is null) { // On fait un saut pour les condition AND et OR si on est dans un {if, while, else if}
	    inst += llist + rlist;
	    inst += new LJump (new LUnop (leftExp, Tokens.NOT), lpaire.faux);
	    inst += rightExp;
	} else if (op.id == Tokens.DPIPE.id && lpaire.vrai !is null) {
	    inst += new LJump (leftExp, lpaire.vrai);
	    inst += rightExp;
	} else {
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, rightExp, op));
	}
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
	inst += new LBinop (left, new LConstDecimal (1, LSize.BYTE), Tokens.XOR);
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
    
    static LInstList InstCast (DecimalConst size) (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, fromDecimalConst (size));
	return inst;
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
	inst += new LConstDecimal (0, LSize.BYTE);
	return inst;
    }

    /**
     Constante de taille du type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList BoolSize (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstDecimal (1, LSize.UBYTE, LSize.BYTE);
	return inst;
    }

    /**
     Constante 'true' de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstTrue (LInstList, LInstList) {
	return new LInstList (new LConstDecimal (1, LSize.BYTE));
    }
    
    /**
     Constante 'false' de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstFalse (LInstList, LInstList) {
	return new LInstList (new LConstDecimal (0, LSize.BYTE));
    }

}
