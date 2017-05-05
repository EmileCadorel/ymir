module semantic.types.ClassUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCall, lint.LFrame, lint.LCast, lint.LAddr;
import std.stdio, lint.LSize, lint.LUnop;


/**
 Cette classe regroupe des fonctions de transformations en lint, commune à tout les objets. 
 */
class ClassUtils {

    static immutable string __AddRef__ = "_YPAddRefObj";
    static immutable string __DstName__ = "_YPDstObj";
    
    static void createFunctions () {
	createAddRef ();
	createDstObj ();
    }
    
    /++
     + Fonction d'ajout d'un référence à un objet.
     + Example:
     + ----------
     + def AddRef (elem : object) {
     +    if (elem !is null)
     +        elem.nbRef++;
     + }
     + ----------
     +/
    static void createAddRef () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG),
				new LConstDecimal (0, LSize.LONG),
				Tokens.NOT_EQUAL);
	
	auto vrai = new LLabel, faux = new LLabel;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	vrai.insts = new LInstList;
	vrai.insts += new LUnop (new LRegRead (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (0, LSize.INT), LSize.LONG), Tokens.DPLUS, true);

	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__AddRef__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__AddRef__] = fr;
	LReg.lastId = last;
    }


    /++
     + Fonction de suppréssion d'une référence d'un objet, et suppréssion si plus de référence.
     + Example:
     + -----------
     + def DstObj (elem : object) {
     +    if (elem !is null) {
     +        elem.nbRef --;
     +        if (elem.nbRef <= 0) free (elem);
     +     }
     + }
     + -----------
     +/
    static void createDstObj () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto entry = new LLabel, end = new LLabel;
	entry.insts = new LInstList;
	auto test = new LBinop (new LRegRead (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG),
					      new LConstDecimal (0, LSize.INT), LSize.INT),
				new LConstDecimal (0, LSize.INT),
				Tokens.INF_EQUAL);

	auto test1 = new LBinop (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG),
				 new LConstDecimal (0, LSize.LONG), Tokens.NOT_EQUAL);
	
	auto vrai1 = new LLabel, vrai = new LLabel, faux = new LLabel;

	entry.insts += new LJump (test1, vrai1);
	entry.insts += new LGoto (faux);
	
	vrai1.insts = new LInstList;
	vrai1.insts += new LUnop (new LRegRead (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (0, LSize.INT), LSize.LONG), Tokens.DMINUS, true);
	
	entry.insts += vrai1;
	vrai1.insts += new LJump (test, vrai);
	vrai1.insts += new LGoto (faux);
	
	vrai.insts = new LInstList;
	vrai.insts += new LCall (new LRegRead (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG),
				 make!(Array!LExp) ([new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG)]),
				 LSize.NONE);
	//vrai.insts += new LSysCall ("free", );
	vrai.insts += new LWrite (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (0, LSize.LONG));
	vrai.insts += new LGoto (faux);
	entry.insts += vrai;

	entry.insts += faux;
	auto fr = new LFrame (__DstName__, entry, end, null, make!(Array!LReg) ([addr]));
	LFrame.preCompiled [__DstName__] = fr;
	LReg.lastId = last;
    }

    
    /**
     Fonction de traitement d'un paramètre de type objet.
     Ajoute un référence en entré de fonction.
     Params:
     llist = les instructions de l'objet
     Returns: la liste d'instruction lint.
     */
    static LInstList InstParam (LInstList llist) {
	auto leftExp = llist.getFirst ();
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) {
	    ClassUtils.createAddRef ();
	}
	llist += new LCall (ClassUtils.__AddRef__, make! (Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	llist += leftExp;
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
	auto leftExp = llist.getFirst ();
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	llist += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	llist += leftExp;
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
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.DEQUAL);
	return inst;
    }

    /**
     Opérateur de test entre deux adresse d'objet '!is'.
     Params:
     llist = les instructions de l'objet de gauche
     rlist = les instructions de l'objet de droite 
     Returns: la liste d'instruction lint.
    */
    static LInstList InstNotIs (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.NOT_EQUAL);
	return inst;
    }

    /**
     Opérateur de test entre l'adresse d'un objet et null ('is').
     Params:
     llist = les instructions de l'objet de gauche
     rlist = les instructions de l'objet de droite 
     Returns: la liste d'instruction lint.
    */
    static LInstList InstIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.DEQUAL);
	return inst;
    }
    
    /**
     Opérateur de test entre l'adresse d'un objet et null ('!is').
     Params:
     llist = les instructions de l'objet de gauche
     rlist = les instructions de l'objet de droite 
     Returns: la liste d'instruction lint.
    */
    static LInstList InstNotIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.NOT_EQUAL);
	return inst;
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
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    /**
     Affecte null à une référence d'objet déjà affecté.
     Supprime la référence.
     Params:
     llist = la liste d'instruction de la référence.
     Returns: la liste d'instruction du lint.
     */
    static LInstList InstAffectNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, new LConstDecimal (0, LSize.LONG));
	return inst;
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
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (ClassUtils.__AddRef__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createAddRef ();
	inst += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (rightExp)]), LSize.NONE);
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    static LInstList InstNop (LInstList, LInstList) {
	return new LInstList ();
    }
    
}
