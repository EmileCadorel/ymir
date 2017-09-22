module ymir.semantic.types.StringUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container, std.stdio;

/**
 Classe regroupant toutes les fonctions nécéssaire à la transformation d'un string en lint.
 */
class StringUtils {

    /** Le nom du constructeur d'un string */
    static immutable string __CstName__ = "_Y4core6string9cstStringFulPaZs";

    /** Le nom du duplicateur de string */
    static immutable string __DupString__ = "_Y4core6string3dupFsZs";

    /** Le nom de la fonction + de deux string */
    static immutable string __PlusString__ = "_Y4core6string14opBinaryNG43GNFssZs";

    /** Le nom de la fonction + de deux string */
    static immutable string __PlusStringChar__ = "_Y4core6string14opBinaryNG43GNFsaZs";

    /** Le nom de la fonction '==' de deux string */
    static immutable string __EqualString__ = "_Y4core6string8opEqualsFssZb";
    

    /**
     Returns: la liste d'instruction d'un operateur d'affectation sur une string déjà affécté.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstString (inst, leftExp, cst);

	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    private static LInstList computeLeftAndRight (ref LExp left, ref LExp right, LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	left = llist.getFirst ();
	right = rlist.getFirst ();
	inst += llist + rlist;
	if (auto call = cast (LCall) left) {
	    auto aux = new LReg (left.size);
	    inst += new LWrite (aux, left);
	    left = aux;
	}

	if (auto call = cast (LCall) right) {
	    auto aux = new LReg (right.size);
	    inst += new LWrite (aux, right);
	    right = aux;
	}
	return inst;
    }

    /**
     Returns: la liste d'instruction d'un operateur plus entre 2 string.
    */
    static LInstList InstPlus (LInstList llist, LInstList rlist) {
	LExp leftExp, rightExp;
	auto inst = computeLeftAndRight (leftExp, rightExp, llist, rlist);
	inst +=  new LCall (__PlusString__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }

    static LInstList InstPlusChar (LInstList llist, LInstList rlist) {
	LExp leftExp, rightExp;
	auto inst = computeLeftAndRight (leftExp, rightExp, llist, rlist);
	inst += new LCall (__PlusStringChar__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }
    
    /**
     Appel de la fonction "=="
     */
    static LInstList InstEqual (LInstList llist, LInstList rlist) {
	LExp leftExp, rightExp;
	auto inst = computeLeftAndRight (leftExp, rightExp, llist, rlist);
	auto call = new LCall (__EqualString__, make!(Array!LExp) (leftExp, rightExp), LSize.BYTE);
	auto ret = new LReg (LSize.BYTE);
	inst += new LWrite (ret, call);
	return  inst;
    }

    /**
     Appel de la fonction !('==')
     */
    static LInstList InstNotEqual (LInstList llist, LInstList rlist) {
	LExp leftExp, rightExp;
	auto inst = computeLeftAndRight (leftExp, rightExp, llist, rlist);
	auto call = new LCall (__EqualString__, make!(Array!LExp) (leftExp, rightExp), LSize.BYTE);
	auto ret = new LReg (LSize.BYTE);
	inst += new LWrite (ret, call);
	inst += new LBinop (ret, ret, Tokens.XOR);
	return  inst;
    }
    
    /**
     Returns: la liste d'instruction d'un operateur += entre 2 string.
    */
    static LInstList InstPlusAffect (LInstList llist, LInstList rlist) {
	LExp leftExp, rightExp;
	auto inst = computeLeftAndRight (leftExp, rightExp, llist, rlist);
	LExp res = new LCall (__PlusString__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);       	
	inst += new LWrite (leftExp, res);
	inst += leftExp;
	return inst;
    }

    /**
     Returns: la liste d'instruction d'une affectation entre une string jamais affecté et une string.
     */
    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	LExp leftExp, rightExp;
	auto inst = computeLeftAndRight (leftExp, rightExp, llist, rlist);
	if (auto cst = cast (LConstString) rightExp) return affectConstStringRight (inst, leftExp, cst);
	inst += new LWrite (leftExp, rightExp);
	inst += leftExp;
	return inst;
    }

    /**
     Returns: la liste d'instruction d'une affectation entre une string jamais affecté et const(ptr!char).
     */
    private static LInstList affectConstStringRight (LInstList inst, LExp leftExp, LConstString rightExp) {	
	Array!LExp exps;
	exps.insertBack (new LConstDecimal (rightExp.value.length, LSize.LONG));
	exps.insertBack (rightExp);

	inst += new LWrite (leftExp, new LCall (__CstName__, exps, LSize.LONG));
	return inst;
    }

    /**
     Returns: la liste d'instruction d'une affectation entre une string et const(ptr!char).
    */
    private static LInstList affectConstString (LInstList inst, LExp leftExp, LConstString rightExp) {	
	Array!LExp exps;
	exps.insertBack (new LConstDecimal (rightExp.value.length, LSize.LONG));
	exps.insertBack (rightExp);

	inst += new LWrite (leftExp, new LCall (__CstName__, exps, LSize.LONG));
	return inst;
    }
    
    /**
     Returns: la liste d'instruction de la transformation d'une string en array (llist);
     */
    static LInstList InstCastArray (LInstList llist) {
	return llist;
    }

    /**
     Returns: La liste d'instruction de récupération de l'adresse du string.
     */
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList ();
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }

    /**
     Returns: la liste d'instruction d'un cast automatique de la chaine vers une string.     
     */
    static LInstList InstComp (LInstList list) {
	auto inst = new LInstList;
	auto rightExp = list.getFirst ();
	if (auto cst = (cast (LConstString) rightExp)) {
	    inst += list;
	    inst += new LCall (__CstName__, make!(Array!LExp) ([new LConstDecimal (cst.value.length, LSize.LONG), cst]), LSize.LONG);
	    return inst;
	} else {
	    inst += list;
	    inst += rightExp;
	    return inst;
	}
    }

}
