module ymir.semantic.types.CharUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.compiler.Compiler;
import ymir.dtarget._;
/**
 Cette classe regroupe toutes les fonctions nécéssaire à la transformation du type char en lint.
*/
class CharUtils {

    /**
     Affectation de deux élément de type char.
     Params:
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LWrite (leftExp, rightExp));
	    return inst;
	} else {
	    auto lexp = cast (DExpression) llist, rexp = cast (DExpression) rlist;
	    return new DBinary (lexp, rexp, Tokens.EQUAL);
	}
    }

    /**
     Opérateur entre deux type char.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
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
     Opérateur entre un type char à gauche et un type int à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpInt (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, new LCast (rightExp, LSize.BYTE), op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DCast (new DType (Dlang.CHAR), cast (DExpression) rlist), op);
	}
    }

    /**
     Opérateur entre un type int à gauche et un type char à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (new LCast (leftExp, LSize.BYTE), rightExp, op));
	    return inst;
	} else {
	    return new DBinary (new DCast (new DType (Dlang.CHAR), cast (DExpression) llist),cast (DExpression) rlist, op);
	}
    }

    
    /**
     Opérateur d'affectation d'un type char.
     Example:
     ------
     a += b;
     ------
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, rightExp, leftExp, op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist,
				new DBinary (cast (DExpression) llist, cast (DExpression) rlist, op),
				Tokens.EQUAL);
	}
    }


    /**
     Opérateur d'affectation d'un type char avec un int à droite.
     Example:
     ---
     a += b;
     ---
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpAffInt (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, new LCast (rightExp, LSize.BYTE), leftExp, op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist,
				new DBinary (cast (DExpression) llist,
					     new DCast (new DType (Dlang.CHAR), cast (DExpression) rlist)
					     , op),
				Tokens.EQUAL);
	}
    }


    /**
     Opérateur de test entre deux type char.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.     
     */
    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
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
     Opérateur de test entre un type char à gauche et un type int à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.     
     */
    static LInstList InstOpTestInt (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (new LCast (leftExp, LSize.INT), rightExp, op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist,
				new DCast (new DType (Dlang.CHAR), cast (DExpression) rlist)
				, op);
	}
    }
    
    /**
     Opérateur de test entre un type int à gauche et un type char à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.     
     */
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, new LCast (rightExp, LSize.INT), op));
	    return inst;
	} else {
	    return new DBinary (new DCast (new DType (Dlang.CHAR), cast (DExpression) llist)
				, cast (DExpression) rlist
				, op);
	}
    }

    
    /**
     La constante d'init d'un char.
     Returns: la liste d'instruction lint.
     */
    static LInstList CharInit (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    inst += new LConstDecimal (0, LSize.BYTE);
	    return inst;
	} else {
	    return new DChar ('\0');
	}
    }

    /**
     La constante de taille d'un char.
     Returns: la liste d'instruction lint.
    */    
    static LInstList CharSizeOf (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    inst += new LConstDecimal (1, LSize.UBYTE, CharInfo.sizeOf);
	    return inst;
	} else {
	    return new DDecimal (LSize.UBYTE);
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
    

}
