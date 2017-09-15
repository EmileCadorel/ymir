module ymir.semantic.types.BoolUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.dtarget._;
import ymir.compiler.Compiler;

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
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += new LWrite (leftExp, rightExp);
	    return inst;
	} else {
	    auto lexp = cast (DExpression) llist, rexp = cast (DExpression) rlist;
	    return new DBinary (lexp, rexp, Tokens.EQUAL);	    
	}
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
	if (COMPILER.isToLint) {
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
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, op);
	}
    }

    
    /**
     Opérateur sur un élément de type bool.
     Params:
     op = l'operateur à appliquer
     llist = les instructions de l'élément de gauche     
     Returns: la liste d'instruction du lint.
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
     Opérateur XOR sur un élément de type bool.
     Params:
     llist = les instructions de l'élément de gauche     
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstXor (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto left = llist.getFirst ();
	    inst += llist;
	    inst += new LBinop (left, new LConstDecimal (1, LSize.BYTE), Tokens.XOR);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.NOT);
	}
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
     Opérateur de récupération de l'adresse d'un type bool.
     Params:
     llist = les instructions de l'élément
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstAddr (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto exp = llist.getFirst ();
	    inst += llist;
	    inst += new LAddr (exp);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.AND);
	}
    }

    /**
     Constante d'init du type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList BoolInit (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    inst += new LConstDecimal (0, LSize.BYTE);
	    return inst;
	} else {
	    return new DBool (false);
	}
    }

    /**
     Constante de taille du type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList BoolSize (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    inst += new LConstDecimal (1, LSize.UBYTE, LSize.BYTE);
	    return inst;
	} else {
	    return new DDecimal (LSize.UBYTE);
	}
    }

    /**
     Constante 'true' de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstTrue (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    return new LInstList (new LConstDecimal (1, LSize.BYTE));
	} else {
	    return new DBool (true);
	}
    }
    
    /**
     Constante 'false' de type bool.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstFalse (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDecimal (0, LSize.BYTE));
	else return new DBool (false);
    }

}
