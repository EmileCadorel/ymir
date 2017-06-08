module semantic.types.StringUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCall, lint.LFrame, lint.LCast, lint.LAddr;
import std.stdio, lint.LSize, lint.LUnop;
import semantic.types.ClassUtils;
import lint.LVisitor, semantic.types.InfoType;
import ast.Expression, ast.Constante, syntax.Word;


/**
 Classe regroupant toutes les fonctions nécéssaire à la transformation d'un string en lint.
 */
class StringUtils {

    /** Le nom du constructeur d'un string */
    static immutable string __CstName__ = "_Y4core6string9cstStringPFulPaZs";

    /** Le nom du duplicateur de string */
    static immutable string __DupString__ = "_Y4core6string3dupPFsZs";

    /** Le nom de la fonction + de deux string */
    static immutable string __PlusString__ = "_Y4core6string14opBinaryNG43GNPFssZs";

    /** Le nom de la fonction + de deux string */
    static immutable string __PlusStringChar__ = "_Y4core6string14opBinaryNG43GNPFsaZs";

    /** Le nom de la fonction '==' de deux string */
    static immutable string __EqualString__ = "_Y4core6string8opEqualsPFssZb";
    

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
     Returns: la liste d'instruction d'un acces à un élément d'un string.
     */
    static LInstList InstAccessS (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto elem = new LBinop (new LConstDecimal (1, LSize.LONG, LSize.LONG),
				new LBinop (leftExp, new LCast (rightExp, LSize.ULONG),
					    Tokens.PLUS),
				Tokens.PLUS);
	
	inst += new LRegRead (elem, new LConstDecimal (0, LSize.INT), LSize.BYTE);
	return inst;
    }

    /**
     Returns: la liste d'instruction de récupération de la taille d'un string.
     */
    static LInstList InstLength (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	if (auto str = (cast(LConstString) leftExp)) {
	    inst += new LConstDecimal (str.value.length, LSize.ULONG);
	} else {
	    inst += new LRegRead (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT, LSize.LONG), LSize.ULONG);
	}
	return inst;
    }

    /**
     Returns: la liste d'instruction de récupération du ptr!char de la string.
     */
    static LInstList InstPtr (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LBinop (cast (LExp) leftExp, new LConstDecimal (1, LSize.INT, LSize.LONG), Tokens.PLUS);
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
