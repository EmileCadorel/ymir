module ymir.semantic.types.ClassUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;
import ymir.dtarget._;
import ymir.compiler.Compiler;

import std.container;


/**
 Cette classe regroupe des fonctions de transformations en lint, commune à tout les objets. 
 */
class ClassUtils {

    static immutable string __DstName__ = "_YPDstObj";


    static LBinop addAllSize (ulong nbLong, ulong nbUlong, ulong nbInt, ulong nbUint, ulong nbShort, ulong nbUshort, ulong nbByte, ulong nbUbyte, ulong nbFloat, ulong nbDouble) {
	return new LBinop (new LConstDecimal (nbLong, LSize.INT, LSize.LONG),
			   new LBinop (new LConstDecimal (nbUlong, LSize.INT, LSize.ULONG),
				       new LBinop (new LConstDecimal (nbInt, LSize.INT, LSize.INT),
						   new LBinop (new LConstDecimal (nbUint, LSize.INT, LSize.UINT),
							       new LBinop (new LConstDecimal (nbShort, LSize.INT, LSize.SHORT),
									   new LBinop (new LConstDecimal (nbUshort, LSize.INT, LSize.USHORT),
										       new LBinop (new LConstDecimal (nbByte, LSize.INT, LSize.BYTE),
												   new LBinop (new LConstDecimal (nbUbyte, LSize.INT, LSize.UBYTE),
													       new LBinop (new LConstDecimal (nbFloat, LSize.INT, LSize.FLOAT),
													       	   	   new LConstDecimal (nbDouble, LSize.INT, LSize.DOUBLE),
															   Tokens.PLUS),
													       Tokens.PLUS),
												   Tokens.PLUS),
										       Tokens.PLUS),
									   Tokens.PLUS),
							       Tokens.PLUS),
						   Tokens.PLUS),
				       Tokens.PLUS),
			   Tokens.PLUS);			   
    }
   
    
    /**
     Fonction de traitement d'un paramètre de type objet.
     Ajoute un référence en entré de fonction.
     Params:
     llist = les instructions de l'objet
     Returns: la liste d'instruction lint.
     */
    static LInstList InstParam (LInstList llist) {
	return llist;	
    }

    /**
     Fonction de traitement d'un retour de type objet.
     Ajoute un référence.
     Params:
     llist = les instructions de l'objet
     Returns: la liste d'instruction lint.
    */
    static LInstList InstReturn (LInstList llist) {
	return llist;
    }
    
    /**
     Opérateur de test entre deux adresse d'objet 'is'.
     Params:
     llist = les instructions de l'objet de gauche
     rlist = les instructions de l'objet de droite 
     Returns: la liste d'instruction lint.
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
     Opérateur de test entre deux adresse d'objet '!is'.
     Params:
     llist = les instructions de l'objet de gauche
     rlist = les instructions de l'objet de droite 
     Returns: la liste d'instruction lint.
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
     Opérateur de test entre l'adresse d'un objet et null ('is').
     Params:
     llist = les instructions de l'objet de gauche
     rlist = les instructions de l'objet de droite 
     Returns: la liste d'instruction lint.
    */
    static LInstList InstIsNull (LInstList llist, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.DEQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DNull, Keys.IS);
	}
    }
    
    /**
     Opérateur de test entre l'adresse d'un objet et null ('!is').
     Params:
     llist = les instructions de l'objet de gauche
     rlist = les instructions de l'objet de droite 
     Returns: la liste d'instruction lint.
    */
    static LInstList InstNotIsNull (LInstList llist, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.NOT_EQUAL);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DNull, Keys.NOT_IS);
	}
    }

    /**
     Affectation d'un référence d'un objet d'une autre référence.
     Suppréssion de la première référence et ajout d'un référence à la seconde.
     Params:
     llist = les instructions de la première référence.
     rlist = les instructions de la deuxième référence.
     Returns: la liste d'instruction du lint.     
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;
	    inst += new LWrite (leftExp, rightExp);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.EQUAL);
	}
    }

    /**
     Affecte null à une référence d'objet déjà affecté.
     Supprime la référence.
     Params:
     llist = la liste d'instruction de la référence.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstAffectNull (LInstList llist, LInstList) {
	if (COMPILER.isToLint) {
	    auto inst = new LInstList;
	    auto leftExp = llist.getFirst ();
	    inst += llist;
	    inst += new LWrite (leftExp, new LConstDecimal (0, LSize.LONG));
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, new DNull (), Tokens.EQUAL);	     
	}
    }

    /**
     Affecte une référence à un objet jamais affecté.
     Ajoute une référence à droite.
     Params:
     llist = la liste d'instruction de la référence de gauche.
     rlist = la liste d'instruction de la référence de droite.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	if (COMPILER.isToLint) {
	    LInstList inst = new LInstList;
	    auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	    inst += llist + rlist;	
	    inst += new LWrite (leftExp, rightExp);
	    return inst;
	} else {
	    return new DBinary (cast (DExpression) llist, cast (DExpression) rlist, Tokens.EQUAL);
	}
    }

    static LInstList InstNop (LInstList, LInstList) {
	return new LInstList ();
    }
    
}
