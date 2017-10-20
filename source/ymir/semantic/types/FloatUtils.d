module ymir.semantic.types.FloatUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.compiler._;
import ymir.dtarget._;

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
     Affectation entre un float et un int.
     Params:
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstAffectInt (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LWrite (leftExp, new LCast (rightExp, LSize.DOUBLE)));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DCast (new DType ("double"), cast (DExpression) rlist), Tokens.EQUAL);
	}
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
     Operateur entre un float et un int.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpInt (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DCast (new DType ("double"), cast (DExpression) rlist), op);
	}
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
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (new LCast (leftExp, LSize.DOUBLE), rightExp, op));
	    return inst;
	} else {
	    return new DBinary (new DCast (new DType ("double"), cast (DExpression) llist), cast (DExpression) rlist, op);
	}
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
     Operateur d'affectation entre un float et un int
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpAffInt (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), leftExp, op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DBinary (cast (DExpression) llist, new DCast (new DType ("double"), cast (DExpression) rlist), op), Tokens.EQUAL);
	}
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
     Operateur de test entre un float et un int.
     Params:
     op = l'operateur
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstOpTestInt (Tokens op) (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (leftExp, new LCast (rightExp, LSize.DOUBLE), op));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DCast (new DType ("double"), cast (DExpression) rlist), op);
	}
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
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += (new LBinop (new LCast (leftExp, LSize.DOUBLE), rightExp, op));
	    return inst;
	} else {
	    return new DBinary (new DCast (new DType ("double"), cast (DExpression) llist), cast (DExpression) rlist, op);
	}
    }
   
    /**
     Operateur de cast vers un long
     Params:
     llist = les instructions de l'operande.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstCastFloat (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LCast (leftExp, LSize.DOUBLE);
	    return inst;
	} else {
	    return new DCast (new DType ("double"), cast (DExpression) llist);
	}
    }

    /**
     Operateur de cast vers un long
     Params:
     llist = les instructions de l'operande.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstCastDec (DecimalConst size) (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LCast (leftExp, fromDecimalConst (size));
	    return inst;
	} else {
	    return new DCast (new DType (fromDecimalConst (size)), cast (DExpression) llist);
	}
    }


    /**
     L'instruction de récuperation de l'adresse d'un float.
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
     La constante d'init d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList FloatInit (LInstList, LInstList) {
	if (COMPILER.isToLint) return new LInstList (new LConstDouble (0.0f));
	else return new DFloat (0.0);
    }

    /**
     La constante max d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Max (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    return new LInstList (new LConstDouble (double.max));
	} else return new DFloat (double.max);
    }

    /**
     La constante min d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Min (LInstList, LInstList) {
	if (COMPILER.isToLint) {
	    return new LInstList (new LConstDouble (double.min_normal));
	} else return new DFloat (double.min_normal);
    }

    /**
     La constante Nan d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Nan (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDouble (double.nan));
	else return new DFloat (double.nan);
    }

    /**
     La constante dig d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Dig (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDecimal (double.dig, LSize.INT));
	else return new DFloat (double.dig);
    }

    /**
     La constante epsilon d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Epsilon (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDouble (double.epsilon));
	else return new DFloat (double.epsilon);
    }

    /**
     La constante mant_dig d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList MantDig (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDecimal (double.mant_dig, LSize.INT));
	else return new DFloat (double.mant_dig);
    }

    /**
     La constante max_10_exp d'un float.
     Returns: la liste d'instruction du lint.
    */
    static LInstList Max10Exp (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDouble (double.max_10_exp));
	else return new DFloat (double.max_10_exp);
    }

    /**
     La constante max_exp d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList MaxExp (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDouble (double.max_exp));
	else return new DFloat (double.max_exp);
    }

    /**
     La constante min_10_exp d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Min10Exp (LInstList, LInstList) {
	if (COMPILER.isToLint)
	    return new LInstList (new LConstDouble (double.min_10_exp));
	else return new DFloat (double.min_10_exp);
    }

    /**
     La constante min_exp d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList MinExp (LInstList, LInstList) {
	if (COMPILER.isToLint)
	    return new LInstList (new LConstDouble (double.min_exp));
	else return new DFloat (double.min_exp);
    }

    /**
     La constante infinity d'un float.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Inf (LInstList, LInstList) {
	if (COMPILER.isToLint) 
	    return new LInstList (new LConstDouble (double.infinity));
	else return new DFloat (double.infinity);
    }

    /**
     Operateur '-' sur un float.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: La liste d'instruction du lint.
     */
    static LInstList InstInv (LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst;
	    inst += llist;
	    inst += new LBinop (new LConstDouble (0), leftExp, Tokens.MINUS);
	    return inst;
	} else {
	    return new DBefUnary (cast (DExpression) llist, Tokens.MINUS);
	}
    }

    /**
     Operateur sqrt sur un float.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: la liste d'instruction du lint.
     */
    static LInstList Sqrt (LInstList, LInstList llist) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto left = llist.getFirst ();
	    inst += llist;
	    inst += new LUnop (left, Tokens.SQRT);
	    return inst;
	} else {
	    COMPILER.getLVisitor!(DVisitor).addDImport (new Namespace ("std.math"));
	    return new DDot (cast (DExpression) llist, new DVar ("sqrt"));
	}
    }

    
}
