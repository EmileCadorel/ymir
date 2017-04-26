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
    static immutable string __CstName__ = "_YPCstString";

    /** Le nom du constructeur d'une string qui ne lui donne aucune reference */    
    static immutable string __CstNameNoRef__ = "_YPCstStringNoRef";

    /** Le nom du duplicateur de string */
    static immutable string __DupString__ = "_YPDupString";

    /** Le nom de la fonction + de deux string */
    static immutable string __PlusString__ = "_YPPlusString";

    /** Le nom de la fonction + de deux string */
    static immutable string __PlusStringChar__ = "_YN32core46string13opBinary4039433941sc";

    /** Le nom de la fonction '==' de deux string */
    static immutable string __EqualString__ = "_YPEqualString";
    
    /**
     Créer toutes les fonctions standarts du type string.
     */
    static void createFunctions () {
	createCstString ();
	createCstStringNoRef ();
	createDupString ();
	createPlusString ();
	createEqualString ();
    }    

    /++
     + Fonction de construction du type string.
     + Example:
     + ----
     + def cstString (size : long, val : ptr!char) : string {
     +    str = malloc (size + 9);
     +    str.int = 1;
     +    (str + 4).int = size;
     +    (str + 8 + size).char = 0;
     +    let i = 0;
     +    while (*val) {
     +        *(str + 8 + i) = *val;
     +        i ++;
     +        val ++;
     +    } 
     +    return str;
     + }
     + ----
     +/
    static void createCstString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.LONG);
	auto addr = new LReg (LSize.LONG);
	Array!LReg args = make!(Array!LReg) (size, addr);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (new LBinop (new LConstDecimal (1, LSize.LONG), size, Tokens.PLUS),
									       new LConstDecimal (3, LSize.INT, LSize.LONG), Tokens.PLUS)]), retReg));
	
	auto index = new LReg (LSize.LONG);
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (1, LSize.LONG))); // Une reference, le symbol ""
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG), new LConstFunc ("free")));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG), size));
	entry.insts += (new LWrite (new LRegRead (new LBinop (retReg, size, Tokens.PLUS), new LConstDecimal (3, LSize.INT, LSize.LONG), LSize.BYTE), new LConstDecimal (0, LSize.BYTE)));
	
	entry.insts += (new LWrite (index, new LConstDecimal (3, LSize.LONG, LSize.LONG)));
	
	auto test = new LBinop (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.BYTE), new LConstDecimal (0, LSize.BYTE), Tokens.NOT_EQUAL);
	auto debut = new LLabel (), vrai = new LLabel, faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

	vrai.insts = new LInstList;
	auto access = new LRegRead (new LBinop (retReg, index, Tokens.PLUS), new LConstDecimal (0, LSize.INT), LSize.BYTE);
	vrai.insts += new LWrite (access, new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.BYTE));
	vrai.insts += new LUnop (addr, Tokens.DPLUS, true);
	vrai.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai.insts += new LGoto (debut);
	
	entry.insts += vrai;
	entry.insts += faux;

	
	LReg.lastId = last;
	auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	LFrame.preCompiled [__CstName__] = fr;
    }




    /++ 
     + Fonction de construction d'un string sans lui attribué de référence.
     + Example:
     + -----
     + def cstStringNoRef (size : long, val : ptr!char) : string {
     +    str = malloc (size + 9);
     +    str.int = 0;
     +    (str + 4).int = size;
     +    (str + size + 8) = 0;
     +    let i = 0;
     +    while (*val) {
     +        *(str + 8 + i) = *val;
     +        i ++;
     +        val ++;
     +    } 
     +    return str;
     + }
     + ----
     +/
    static void createCstStringNoRef () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.LONG);
	auto addr = new LReg (LSize.LONG);
	Array!LReg args = make!(Array!LReg) (size, addr);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (new LBinop (new LConstDecimal (1, LSize.LONG), size, Tokens.PLUS),
									       new LConstDecimal (3, LSize.INT, LSize.LONG), Tokens.PLUS)]), retReg));
	auto index = new LReg (LSize.LONG);
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (0, LSize.LONG))); // Une reference, le symbol ""
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG), new LConstFunc ("free")));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG), size));
	entry.insts += (new LWrite (new LRegRead (new LBinop (retReg, size, Tokens.PLUS), new LConstDecimal (3, LSize.INT, LSize.LONG), LSize.BYTE), new LConstDecimal (0, LSize.BYTE)));
	
	entry.insts += (new LWrite (index, new LConstDecimal (3, LSize.LONG, LSize.LONG)));
	
	auto test = new LBinop (new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.BYTE), new LConstDecimal (0, LSize.BYTE), Tokens.NOT_EQUAL);
	auto debut = new LLabel (), vrai = new LLabel, faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

	vrai.insts = new LInstList;
	auto access = new LRegRead (new LBinop (retReg, index, Tokens.PLUS), new LConstDecimal (0, LSize.INT), LSize.BYTE);
	vrai.insts += new LWrite (access, new LRegRead (addr, new LConstDecimal (0, LSize.INT), LSize.BYTE));
	vrai.insts += new LUnop (addr, Tokens.DPLUS, true);
	vrai.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai.insts += new LGoto (debut);
	
	entry.insts += vrai;
	entry.insts += faux;

	
	LReg.lastId = last;
	auto fr = new LFrame (__CstNameNoRef__, entry, end, retReg, args);
	LFrame.preCompiled [__CstNameNoRef__] = fr;
    }

    
    /++
     + Fonction de duplication du type string.
     + Example:
     + ----
     + def dupString (str:string) {
     +    let aux = malloc (str.length + 9);
     +    aux.int = 1;
     +    (aux+4).int = str.length;
     +    let i = 0;
     +    while (i < str.length + 1) {
     +        aux [i] = str [i];
     +        i ++;
     +    }
     +    return aux;
     + }
     + ----
     +/
    static void createDupString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG), retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	
	LExp size = new LBinop (new LBinop (new LConstDecimal (1, LSize.LONG), new LRegRead (addr, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG), Tokens.PLUS),
				new LConstDecimal (3, LSize.INT, LSize.LONG), Tokens.PLUS);
	
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([size]), retReg);
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (1, LSize.INT));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG), new LConstFunc ("free"));
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
				   new LRegRead (addr, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG));
	
    
	entry.insts += new LWrite (index, new LConstDecimal (0, LSize.LONG));
	size = new LRegRead (addr, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG);
    
	auto test = new LBinop (index, new LBinop (size, new LConstDecimal (1, LSize.INT), Tokens.PLUS), Tokens.INF);
	auto debut = new LLabel, vrai = new LLabel (new LInstList), faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);

	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.BYTE), Tokens.STAR),
								    new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),						
						Tokens.PLUS),
				    new LConstDecimal (0, LSize.INT), LSize.BYTE);
	
	vrai.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr, new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.BYTE), Tokens.STAR),
										Tokens.PLUS),
								    new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS)
							, new LConstDecimal (0, LSize.INT), LSize.BYTE));
	
	vrai.insts += new LBinop (index, new LConstDecimal (1, LSize.LONG), index, Tokens.PLUS);
	vrai.insts += new LGoto (debut);
	entry.insts += vrai;
	entry.insts += faux;
	auto fr = new LFrame (__DupString__, entry, end, retReg, make!(Array!LReg) (addr));
	LFrame.preCompiled [__DupString__] = fr;
	LReg.lastId = last;
	
    }

    /++
     + Fonction de test de deux string
     + Example:
     + --------
     + def equalString (left : string, right : string) {
     +     if (left.length != right.length) return false;
     +     for (it in 0UL .. left.length) {
     +         if (left [it] != right [it]) return false;
     +     }
     +     return true;
     + }
     + --------
     +/
    static void createEqualString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto left = new LReg (LSize.LONG), right = new LReg (LSize.LONG), retReg = new LReg (LSize.BYTE);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.ULONG);
	auto test1 = new LBinop (new LRegRead (left, new LConstDecimal (2, LSize.INT, LSize.ULONG), LSize.ULONG),
				 new LRegRead (right, new LConstDecimal (2, LSize.INT, LSize.ULONG), LSize.ULONG),
				 Tokens.NOT_EQUAL);
	
	auto vrai = new LLabel (new LInstList), faux = new LLabel;
	entry.insts += new LJump (test1, vrai);
	entry.insts += new LGoto (faux);
	entry.insts += vrai;
	entry.insts += faux;
	vrai.insts += new LWrite (retReg, new LConstDecimal (0, LSize.BYTE));
	vrai.insts += new LGoto (end);

	auto debut = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += new LWrite (index, new LConstDecimal (0, LSize.ULONG));
	auto size = new LRegRead (left, new LConstDecimal (2, LSize.INT, LSize.ULONG), LSize.ULONG);
	
	auto test = new LBinop (index, size, Tokens.INF);	
	entry.insts += debut;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);
	entry.insts += vrai2;
	entry.insts += faux2;
	auto leftAccess = new LRegRead (new LBinop (left, new LBinop (new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.BYTE), Tokens.STAR),
								    new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),						
						Tokens.PLUS),
				    new LConstDecimal (0, LSize.INT), LSize.BYTE);

	auto rightAccess = new LRegRead (new LBinop (right, new LBinop (new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.BYTE), Tokens.STAR),
								    new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),						
						Tokens.PLUS),
				    new LConstDecimal (0, LSize.INT), LSize.BYTE);
	
	auto test2 = new LBinop (leftAccess, rightAccess, Tokens.NOT_EQUAL);
	auto vrai3 = new LLabel (new LInstList), faux3 = new LLabel;
	vrai2.insts += new LJump (test2, vrai3);
	vrai2.insts += new LGoto (faux3);
	vrai2.insts += vrai3;
	vrai2.insts += faux3;
	vrai3.insts += new LWrite (retReg, new LConstDecimal (0, LSize.BYTE));
	vrai3.insts += new LGoto (end);
	vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai2.insts += new LGoto (debut);
	entry.insts += new LWrite (retReg, new LConstDecimal (1, LSize.BYTE));
	auto fr = new LFrame (__EqualString__, entry, end, retReg, make!(Array!LReg) (left, right));
	LFrame.preCompiled [__EqualString__] = fr;
	LReg.lastId = last;
    }
    
    /++
     + Fonction d'un plus sur deux string
     + Example:
     + ---
     + def plusString (a : string, b : string) {
     +    let x = malloc (3 * long + a.length + b.length + 1);
     +    x.nbRef = 1;
     +    x.length = a.length + b.length.
     +    x [size] = 0;
     +    x.dst = $free;
     +    for (i in 0 .. a.length) x [i] = a [i];
     +    for (j in 0 .. b.length) x [j + a.length] = b[j];
     +    return x;
     + }
     + ---
     +/
    static void createPlusString () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
							      new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
							      Tokens.PLUS),
						  new LConstDecimal (1, LSize.INT, LSize.BYTE), Tokens.STAR),
				      new LConstDecimal (3, LSize.INT, LSize.LONG), Tokens.PLUS);
	
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([new LBinop (new LConstDecimal (1, LSize.LONG), globalSize, Tokens.PLUS)]), retReg);
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (1, LSize.LONG));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG), new LConstFunc ("free"));
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
				   new LBinop (new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
					       new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
					       Tokens.PLUS));
	
	entry.insts += new LWrite (new LRegRead (new LBinop (retReg,
							     new LBinop (new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
									 new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
									 Tokens.PLUS),
							     Tokens.PLUS),
						 new LConstDecimal (3, LSize.INT, LSize.LONG),
						 LSize.BYTE),
				   new LConstDecimal (0, LSize.BYTE));
				   
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstDecimal (0, LSize.LONG));
	entry.insts += new LWrite (size, new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG));
	auto test = new LBinop (index, size, Tokens.INF);
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);
	
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.BYTE), Tokens.STAR),
								    new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),
						Tokens.PLUS),
				    new LConstDecimal (0, LSize.BYTE), LSize.BYTE);
	
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.BYTE), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS)
							 , new LConstDecimal (0, LSize.INT), LSize.BYTE));
	
	vrai1.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai1.insts += new LGoto (debut1);
	entry.insts += vrai1;
	entry.insts += faux1;

	// index2 = 8;
	entry.insts += new LWrite (index2, new LConstDecimal (0, LSize.LONG));
	entry.insts += new LWrite (size, new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG));
	
	test = new LBinop (index2, size, Tokens.INF);
	auto debut2 = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += debut2;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);
	
	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstDecimal (1, LSize.LONG, LSize.BYTE), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS)
							 , new LConstDecimal (0, LSize.INT), LSize.BYTE));
	
	vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai2.insts += new LUnop (index2, Tokens.DPLUS, true);
	vrai2.insts += new LGoto (debut2);
	entry.insts += vrai2;
	entry.insts += faux2;
	
	auto fr = new LFrame (__PlusString__, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusString__] = fr;
	LReg.lastId = last;
    }
    

    /**
     Returns: la liste d'instruction d'un operateur d'affectation sur une string déjà affécté.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstString (inst, leftExp, cst);

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
     Returns: la liste d'instruction d'un operateur plus entre 2 string.
    */
    static LInstList InstPlus (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (__PlusString__ in LFrame.preCompiled);
	if (it is null) createPlusString ();
	inst +=  new LCall (__PlusString__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }

    static LInstList InstPlusChar (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	inst += new LCall (__PlusStringChar__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }
    
    /**
     Appel de la fonction "=="
     */
    static LInstList InstEqual (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__EqualString__ in LFrame.preCompiled);
	if (it is null) createEqualString ();
	auto call = new LCall (__EqualString__, make!(Array!LExp) (leftExp, rightExp), LSize.BYTE);
	auto ret = new LReg (LSize.BYTE);
	inst += new LWrite (ret, call);
	return  inst;
    }

    /**
     Appel de la fonction !('==')
     */
    static LInstList InstNotEqual (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__EqualString__ in LFrame.preCompiled);
	if (it is null) createEqualString ();
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
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto it = (__PlusString__ in LFrame.preCompiled);
	if (it is null) createPlusString ();
	auto res = new LCall (__PlusString__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	auto aux = new LReg (LSize.LONG);
	inst += new LWrite (aux, res);
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();	
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, aux);
	inst += new LUnop (new LRegRead (cast (LExp)leftExp, new LConstDecimal (0, LSize.INT), LSize.LONG), Tokens.DPLUS, true);
	
	inst += aux;
	return inst;
    }

    /**
     Returns: la liste d'instruction d'une affectation entre une string jamais affecté et une string.
     */
    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	if (auto cst = cast (LConstString) rightExp) return affectConstStringRight (inst, leftExp, cst);
	inst += new LUnop (new LRegRead (cast (LExp)rightExp, new LConstDecimal (0, LSize.INT), LSize.LONG), Tokens.DPLUS, true);	
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    /**
     Returns: la liste d'instruction d'une affectation entre une string jamais affecté et const(ptr!char).
     */
    private static LInstList affectConstStringRight (LInstList inst, LExp leftExp, LConstString rightExp) {	
	Array!LExp exps;
	exps.insertBack (new LConstDecimal (rightExp.value.length, LSize.LONG));
	exps.insertBack (rightExp);
	auto it = (__CstName__ in LFrame.preCompiled);
	if (it is null) {
	    createCstString ();
	}

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
	auto it = (__CstName__ in LFrame.preCompiled);
	if (it is null) createCstString ();
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();

	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp)([new LAddr (leftExp)]), LSize.NONE);
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
	auto elem = new LBinop (new LConstDecimal (3, LSize.LONG, LSize.LONG),
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
	    inst += new LRegRead (cast (LExp) leftExp, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.ULONG);
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
	inst += new LBinop (cast (LExp) leftExp, new LConstDecimal (3, LSize.INT, LSize.LONG), Tokens.PLUS);
	return inst;
    }

    
    /**
     Returns: la liste d'instruction de récupération du nombre de référence de la string.
     */
    static LInstList InstNbRef (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	if (auto str = (cast(LConstString) leftExp)) {
	    inst += new LConstDecimal (0, LSize.ULONG);
	} else {
	    inst += new LRegRead (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT), LSize.ULONG);
	}
	return inst;
    }

    /**
     Returns: la liste d'instruction de la déstruction d'une string.
     */
    static LInstList InstDestruct (LInstList llist) {
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) {
	    ClassUtils.createDstObj ();
	}
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (expr)]), LSize.NONE);
	return inst;
    }

    /**
     Returns: la liste d'instruction de duplication d'une string.
     */
    static LInstList InstDup (LInstList, LInstList rlist) {
	auto inst = new LInstList;
	auto rightExp = rlist.getFirst ();
	if (auto cst = cast (LConstString) rightExp) {
	    auto it = (__CstName__ in LFrame.preCompiled);
	    if (it is null) createCstString ();
	    inst += rlist;
	    inst += new LCall (__CstName__, make!(Array!LExp) ([new LConstDecimal (cst.value.length, LSize.LONG), cst]), LSize.LONG);
	    return inst;
	} else {
	    auto it = (__DupString__ in LFrame.preCompiled);
	    if (it is null) createDupString ();	
	    auto expr = rlist.getFirst ();
	    inst += rlist;
	    inst += new LCall (__DupString__, make!(Array!LExp) ([expr]), LSize.LONG);
	    return inst;
	}
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
	    auto it = (__CstNameNoRef__ in LFrame.preCompiled);
	    if (it is null) createCstStringNoRef ();
	    inst += list;
	    inst += new LCall (__CstNameNoRef__, make!(Array!LExp) ([new LConstDecimal (cst.value.length, LSize.LONG), cst]), LSize.LONG);
	    return inst;
	} else {
	    inst += list;
	    inst += rightExp;
	    return inst;
	}
    }

    /**
     Returns: la liste d'instruction de récupération du nom du type.
     */
    static LInstList GetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	inst += LVisitor.visitExpressionOutSide (left);
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    /**
     Returns: left.
     */
    static LInstList StringOf (LInstList, LInstList left) {
	return left;
    }


}
