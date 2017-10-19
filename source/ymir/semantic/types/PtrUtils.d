module ymir.semantic.types.PtrUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.compiler._;
import ymir.dtarget._;

import std.container;

/**
 Cette classe regroupe les fonctions nécéssaire à la transformation de ptr vers le lint.
 */
class PtrUtils {

    /**
     Affectation d'un pointeur.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LWrite (leftExp, rightExp));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.EQUAL);
	}
    }
    
    /**
     Affectation d'un pointeur à null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: les instructions du lint.
     */
    static LInstList InstAffectNull (LInstList llist, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += (new LWrite (leftExp, new LConstDecimal (0, LSize.LONG)));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DNull (), Tokens.EQUAL);
	}
    }

    /**
     Application d'un opérateur entre deux pointeur..
     Params:
     size = je sais pas.
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOp (LSize size, Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new  LBinop (leftExp, new LCast (rightExp, LSize.ULONG), op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, op);
	}
    }
   
    /**
     Application d'un opérateur entre deux pointeur à droite.
     Params:
     size = je sais pas.
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpInv (LSize size, Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {	
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new  LBinop (new LCast (rightExp, LSize.ULONG), leftExp, op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) rlist, cast (DExpression) llist, op);
	}
    }

    /**
     Application d'un accés à la valeur pointé.
     Params:
     size = la taille de l'élément pointé.
     llist = les instructions de l'operande.
     Returns: les instructions de l'accés en lint.
     */
    static LInstList InstUnref (LSize size) (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LRegRead (leftExp, new LConstDecimal (0, LSize.INT), size);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.STAR);
	}
    }

    /**
     Application d'un accés à la valeur pointé, (a partir d'un operateur '.').
     Params:
     size = la taille de l'élément pointé.
     llist = les instructions de l'operande.
     Returns: les instructions de l'accés en lint.     
     */
    static LInstList InstUnrefDot (LSize size) (LInstList, LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LRegRead (leftExp, new LConstDecimal (0, LSize.INT), size);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.STAR);
	}
    }

    /**
     Application de l'operateur de test d'egalité.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste d'instruction du test en lint.
     */
    static LInstList InstIs (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += new LBinop (leftExp, rightExp, Tokens.DEQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Keys.IS);
	}
    }

    
    /**
     Application de l'operateur de test d'inégalité.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste d'instruction du test en lint.
     */
    static LInstList InstNotIs (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += new LBinop (leftExp, rightExp, Tokens.NOT_EQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Keys.NOT_IS);
	}
    }

    /**
     Application de l'operateur de test d'inégalité, avec null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: la liste d'instruction du test en lint.
     */
    static LInstList InstNotIsNull (LInstList llist, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.NOT_EQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DNull (), Keys.NOT_IS);
	}
    }

    /**
     Application de l'operateur de test d'égalité, avec null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: la liste d'instruction du test en lint.
    */
    static LInstList InstIsNull (LInstList llist, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.DEQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DNull (), Keys.IS);
	}
    }

    /**
     Returns: la liste d'instruction de la constante null.
     */
    static LInstList InstNull (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    inst += new LConstDecimal (0, LSize.LONG);
	    return inst;
	} else {
	    return new DNull ();
	}
    }

    /**
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: la liste d'instruction d'un cast d'un pointeur vers un autre (llist).
     */
    static LInstList InstCast (LInstList llist) {
	return llist;
    }

    /**
     L'instruction de récuperation de l'addresse d'un ptr.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }


    
}


