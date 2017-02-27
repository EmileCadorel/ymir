module semantic.types.ArrayUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LFrame, lint.LCall, lint.LAddr;
import semantic.types.StringUtils, lint.LSize, lint.LUnop;
import semantic.types.ClassUtils, semantic.types.InfoType;
import ast.Expression, lint.LVisitor, semantic.types.ArrayInfo;
import ast.Constante, syntax.Word, ast.ParamList;
import std.traits;

/**
 Cette classe contient un ensemble de fonctions statique qui permettent la transformation d'un tableau en lint.
 */
class ArrayUtils {

    static immutable string __CstName__ = "_YPCstArray";
    static immutable string __CstNameObj__ = "_YPCstArrayObj";
    static immutable string __PlusArray__ = "_YPPlusArray";
    static immutable string __PlusArrayObj__ = "_YPPlusArrayObj";
    static immutable string __DstArray__ = "_YPDstArray";

    static void createFunctions () {
	createCstArray ();
	createCstArray (__DstArray__);
	createDstArray ();
	foreach (it ; [EnumMembers!LSize]) {
	    if (it != LSize.NONE)
		createPlusArray (it);
	}
	createPlusArrayObj ();
    }
    
    
    /++
     + Fonction de construction d'un tableau en lint.
     + Example:
     + ---
     + def cstArray (size : int, ofsize : int) {
     +    let arr = malloc (size + 3 * long);
     +    arr.long = 1;
     +    (arr + long) = $destruct
     +    (arr + 2 * long).long = size / ofsize;
     +    return arr;
     + }
     + ---
     + Params:
     + dstName = le nom du destructeur du tableau.
     +/
    static void createCstArray (string dstName = "free") {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.LONG);
	auto ofsize = new LReg (LSize.LONG);
	Array!LReg args = make!(Array!LReg) (size, ofsize);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (), end = new LLabel;
	entry.insts = new LInstList;
	entry.insts += (new LSysCall ("alloc", make!(Array!LExp)
				      ([new LBinop (size, new LConstDecimal (3, LSize.INT, LSize.LONG),
						    Tokens.PLUS)]), retReg));
	
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG),
				    new LConstDecimal (1, LSize.LONG)));
	
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
				    new LBinop (size,
						ofsize,
						Tokens.DIV)));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG),
				    new LConstFunc (dstName)));

	if (dstName == "free") {
	    auto fr = new LFrame (__CstName__, entry, end, retReg, args);
	    LFrame.preCompiled [__CstName__] = fr;
	} else {
	    auto fr = new LFrame (__CstNameObj__, entry, end, retReg, args);
	    LFrame.preCompiled [__CstNameObj__] = fr;
	}
	LReg.lastId = last;
    }    
    
    /++
     + Fonction de destruction du tableau (si il contient des objets).
     + Example:
     + ---
     + def dstArray (a : array!object) {
     +    for (i in a) 
     +         dstObj (i);
     +    free (a);
     + }
     + ---     
     +/
    static void createDstArray () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr = new LReg (LSize.LONG);
	auto size = new LReg (LSize.LONG);
	auto index = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	entry.insts += new LWrite (index, new LConstDecimal (0, LSize.LONG));
	auto test = new LBinop (index, new LRegRead (addr, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG), Tokens.INF);
	auto debut = new LLabel, vrai = new LLabel (new LInstList), faux = new LLabel;
	entry.insts += debut;
	entry.insts += new LJump (test, vrai);
	entry.insts += new LGoto (faux);
	auto where = new LBinop (addr, new LBinop (new LConstDecimal (3, LSize.LONG, LSize.LONG),
						   new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.LONG), Tokens.STAR), Tokens.PLUS), Tokens.PLUS);
	vrai.insts += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([where]), LSize.NONE);
	vrai.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai.insts += new LGoto (debut);
	entry.insts += vrai;
	entry.insts += faux;
	entry.insts += new LSysCall ("free", make!(Array!LExp) ([addr]));
	auto fr = new LFrame (__DstArray__, entry, end, null, make!(Array!LReg) (addr));
	LFrame.preCompiled [__DstArray__] = fr;
	LReg.lastId = last;
    }       

    /++
     + Fonctions d'addition de deux tableau en lint. 
     + Example:
     + ---
     + def plusArray (a1 : array!T, a2 : array!T) {
     +    let arr = malloc (a1.size + a2.size + 3 * long);
     +    arr.long = 1;
     +    (arr + long).long = (a1 + long).long;
     +    arr.size = a1.size + a2.size;
     +    let i = 0;
     +    while (i < a1.size) {
     +        arr[i] = a1[i];
     +        i++;
     +    }
     +    let j = 0;
     +    while (j < a2.size) {
     +        arr [i] = a2 [j];
     +        j ++;
     +        i ++;
     +    }
     +    return arr;
     + }
     + ---
     + Params:
     + _psize = la taille du type contenu dans le tableau.
     +/
    static void createPlusArray (LSize _psize) {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
							      new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
							      Tokens.PLUS),
						  new LConstDecimal (1, LSize.INT, LSize.LONG), Tokens.STAR),
				      new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS);
	
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (1, LSize.LONG));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG),
				    new LConstFunc ("free")));
	
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
				   new LBinop (new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
					       new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
					       Tokens.PLUS));
	
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstDecimal (0, LSize.LONG));
	entry.insts += new LWrite (size, new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG)); // size = addr1 [2 * long]
	auto test = new LBinop (index, size, Tokens.INF);
	
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);
	
	// array [3 * long + index * int];
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstDecimal (1, LSize.LONG, _psize), Tokens.STAR),
								    new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),
						Tokens.PLUS), new LConstDecimal (0, LSize.INT), _psize);
	
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstDecimal (1, LSize.LONG, _psize), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),
							 new LConstDecimal (0, LSize.INT), _psize));
	
	vrai1.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai1.insts += new LGoto (debut1);
	entry.insts += vrai1;
	entry.insts += faux1;

	// index2 = 8;
	entry.insts += new LWrite (index2, new LConstDecimal (0, LSize.LONG));
	entry.insts += new LWrite (size, new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG)); // size = addr2 [2 * long]
	
	test = new LBinop (index2, size, Tokens.INF);
	auto debut2 = new LLabel, vrai2 = new LLabel (new LInstList), faux2 = new LLabel;
	entry.insts += debut2;
	entry.insts += new LJump (test, vrai2);
	entry.insts += new LGoto (faux2);

	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstDecimal (1, LSize.LONG, _psize), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS)
							 , new LConstDecimal (0, LSize.INT), _psize)); // addr2 [3 * long + index2 * int];
	
	vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai2.insts += new LUnop (index2, Tokens.DPLUS, true);
	vrai2.insts += new LGoto (debut2);
	entry.insts += vrai2;
	entry.insts += faux2;
	
	auto fr = new LFrame (__PlusArray__ ~ _psize.value, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusArray__ ~ _psize.value] = fr;
	LReg.lastId = last;
    }

    /++
     + Addition de deux tableaux qui contiennent de objets.     
     + Example:
     + ---
     + def plusArray (a1 : array!Object, a2 : array!Object) {
     +    let arr = malloc (a1.size + a2.size + 3 * long);
     +    arr.long = 1;
     +    (arr + long).long = (a1 + long).long;
     +    arr.size = a1.size + a2.size;
     +    let i = 0;
     +    while (i < a1.size) {
     +        arr[i] = a1[i];
     +        i++;
     +    }
     +    let j = 0;
     +    while (j < a2.size) {
     +        arr [i] = a2 [j];
     +        j ++;
     +        i ++;
     +    }
     +    return arr;
     + }
     + ---
     +/
    static void createPlusArrayObj () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto addr1 = new LReg (LSize.LONG), addr2 = new LReg (LSize.LONG), size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel ();
	auto index = new LReg (LSize.LONG);
	
	auto globalSize = new LBinop (new LBinop (new LBinop (new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
							      new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
							      Tokens.PLUS),
						  new LConstDecimal (1, LSize.INT, LSize.LONG), Tokens.STAR),
				      new LConstDecimal (3, LSize.INT, LSize.LONG), Tokens.PLUS); // taille = (addr1 [2 * long] + addr2 [2 * long]) * long + 3 * long;
	
	auto index2 = new LReg (LSize.LONG);
	entry.insts += new LSysCall ("alloc",
				     make!(Array!LExp) ([globalSize]), retReg);
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (0, LSize.INT), LSize.LONG), new LConstDecimal (1, LSize.INT));
	entry.insts += (new LWrite (new LRegRead (retReg, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG),
				    new LRegRead (addr1, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.LONG))); // on recupere le destructeur
			
	entry.insts += new LWrite (new LRegRead (retReg, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
				   new LBinop (new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
					       new LRegRead (addr2, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG),
					       Tokens.PLUS));
	
	// index = 8, size = addr1.length + 8
	entry.insts += new LWrite (index,  new LConstDecimal (0, LSize.LONG));
	entry.insts += new LWrite (size, new LRegRead (addr1, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG));
	auto test = new LBinop (index, size, Tokens.INF);
	
	auto debut1 = new LLabel, vrai1 = new LLabel (new LInstList), faux1 = new LLabel;
	entry.insts += debut1;
	entry.insts += new LJump (test, vrai1);
	entry.insts += new LGoto (faux1);

	// access = array [3 * long + size * long]
	auto access = new LRegRead (new LBinop (retReg, new LBinop (new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.LONG), Tokens.STAR),
								    new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),
						Tokens.PLUS),
				    new LConstDecimal (0, LSize.INT), LSize.LONG);
	
	vrai1.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr1, new LBinop (index, new LConstDecimal (1, LSize.LONG, LSize.LONG), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS)
							 , new LConstDecimal (0, LSize.INT), LSize.LONG));
	vrai1.insts += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (access)]), LSize.NONE);
	
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
	
	vrai2.insts += new LWrite (access, new LRegRead (new LBinop (new LBinop (addr2, new LBinop (index2, new LConstDecimal (1, LSize.LONG, LSize.LONG), Tokens.STAR),
										 Tokens.PLUS),
								     new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS)
							 , new LConstDecimal (0, LSize.INT), LSize.LONG));
	vrai2.insts += new LCall (ClassUtils.__AddRef__, make!(Array!LExp) ([new LAddr (access)]), LSize.NONE);
	vrai2.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai2.insts += new LUnop (index2, Tokens.DPLUS, true);
	vrai2.insts += new LGoto (debut2);
	entry.insts += vrai2;
	entry.insts += faux2;
	
	auto fr = new LFrame (__PlusArrayObj__, entry, end, retReg, make!(Array!LReg) (addr1, addr2));
	LFrame.preCompiled [__PlusArrayObj__] = fr;
	LReg.lastId = last;
    }    
    
    /**
     Affect un tableau (qui n'a pas encore été affecté) à null, .
     Returns: les instructions du lint.
     */
    static LInstList InstAffectNullRight (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LWrite (leftExp, new LConstDecimal (0, LSize.LONG));
	return inst;
    }

    /** 
     Destruit un tableau.
     Params:
     llist = les instructions du tableau.
     Returns: les instructions du lint.
     */
    static LInstList InstDestruct (LInstList llist) {
	auto it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (expr)]), LSize.NONE);
	return inst;
    }
    
    /**
     Recherche la taille du tableau.
     Params:
     list = les instructions du tableaux.
     Returns: les instructions du lint.
     */
    static LInstList InstLength (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LRegRead (cast (LExp) leftExp, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG);
	return inst;
    }

    /**
     Recherche le nombre de reference du tableau.
     Params:
     list = les instructions du tableau.
     Returns: les instructions du lint.
     */
    static LInstList InstNbRef (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LRegRead (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT), LSize.LONG);
	return inst;
    }
    

    /**
     Additionne deux tableau.
     Params:
     size = la taille du contenu du tableau.
     llist = les instructions du tableau de gauche.
     rlist = les instructions du tableau de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstPlus (LSize size) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__PlusArray__ ~ size.value in LFrame.preCompiled);
	if (it is null) createPlusArray (size);
	inst += new LCall (__PlusArray__ ~ size.value, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }

    /**
     Additionne et affecte deux tableau (a += b);
     Params:
     size = la taille du contenu du tableau.
     llist = les instructions du tableau de gauche
     rlist = les instructions du tableau de droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstPlusAff (LSize size) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__PlusArray__ ~ size.value in LFrame.preCompiled);
	if (it is null) createPlusArray (size);
	auto res = new LCall (__PlusArray__ ~ size.value, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	auto aux = new LReg (LSize.LONG);
	inst += new LWrite (aux, res);
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	
	inst += new LWrite (leftExp, aux);
	inst += new LUnop (new LRegRead (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT), LSize.LONG), Tokens.DPLUS, true);
	inst += aux;
	return inst;
    }

    /**
     Additionne deux tableaux qui contiennent des objets.
     Params:
     llist = les instructions du tableau de gauche.
     rlist = les instructions du tableau de droite.
     Returns: Les instructions du lint.
     */
    static LInstList InstPlusObj (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__PlusArrayObj__ in LFrame.preCompiled);
	if (it is null) createPlusArrayObj ();
	inst += new LCall (__PlusArrayObj__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	return inst;
    }

    /**
     Additionne et affecte deux tableaux qui contiennent des objets (a += b).
     Params:
     llist = les instructions du tableau de gauche.
     rlist = les instructions du tableau de droite.
     Returns: Les instructions du lint.
     */
    static LInstList InstPlusAffObj (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst, rightExp = rlist.getFirst;
	inst += llist + rlist;
	auto it = (__PlusArrayObj__ in LFrame.preCompiled);
	if (it is null) createPlusArrayObj ();
	auto res = new LCall (__PlusArrayObj__, make!(Array!LExp) (leftExp, rightExp), LSize.LONG);
	auto aux = new LReg (LSize.LONG);
	inst += new LWrite (aux, res);
	it = (ClassUtils.__DstName__ in LFrame.preCompiled);
	if (it is null) ClassUtils.createDstObj ();
	inst += new LCall (ClassUtils.__DstName__, make!(Array!LExp) ([new LAddr (leftExp)]), LSize.NONE);
	inst += new LWrite (leftExp, aux);
	inst += new LUnop (new LRegRead (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT), LSize.LONG), Tokens.DPLUS, true);
	inst += aux;
	return inst;
    }

    /**
     Accède à une case du tableau.
     Params:
     size = la taille du type contenu dans le tableau.
     llist = les instructions du type de gauche
     rlists = les instructions des paramètres.
     Returns: les instructions lint.
     */
    static LInstList InstAccessS (LSize size) (LInstList llist, Array!LInstList rlists) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlists.back ().getFirst ();
	inst += llist + rlists.back ();
	auto elem = new LBinop (new LConstDecimal (3, LSize.LONG, LSize.LONG),
				new LBinop (leftExp,
					    new LBinop (new LCast (rightExp, LSize.ULONG),
							new LConstDecimal (1, LSize.LONG, size),
							Tokens.STAR),
					    Tokens.PLUS),
				Tokens.PLUS);
	inst += new LRegRead (elem, new LConstDecimal (0, LSize.INT), size);	
	return inst;
    }

    /**
     Transforme le tableau en string.
     Params:
     llist = les instructions du tableau.
     Returns: les instructions du lint.
     */
    static LInstList InstCastString (LInstList llist) {
	return llist;
    }

    /**
     Recupere le string qui contient le type du tableau.
     Params:
     left = l'expression du tableau.
     Returns: les instructions lint.
     */
    static LInstList ArrayGetType (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	inst += LVisitor.visitExpressionOutSide (left);
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    /**
     Returns: Retourne le string qui contient le nom du tableau (necessite ArrayGetType au préalable).     
     */
    static LInstList ArrayStringOf (LInstList, LInstList left) {
	return left;
    }
    
    /**
     Création de la boucle d'itération du tableau.
     Params:
     _type = le type du tableau qui contient les informations utiles (retourner par ApplyOp);
     _left = l'expression du tableau.
     _right = un ParamList qui contient les variable itérateurs (ici juste une).
     Returns: la boucle (le label de fin est accessible avec (.back ())).
     */
    static LInstList InstApplyPreTreat (InfoType _type, Expression _left, Expression _right) {
	auto inst = new LInstList;
	auto type = cast (ArrayInfo) _type;
	auto left = LVisitor.visitExpressionOutSide (_left);
	for (long nb = _left.info.type.lintInstS.length - 1; nb >= 0; nb --) 
	    left = _left.info.type.lintInst (left, nb);
	
	auto right = LVisitor.visitExpressionOutSide ((cast (ParamList) _right).params [0]);
	
	auto leftExp = left.getFirst(), rightExp = right.getFirst ();
	inst += left + right;
	auto debut = new LLabel, vrai = new LLabel (new LInstList), block = new LLabel ("tmp_block");
	auto faux = new LLabel;
	auto index = new LReg (LSize.LONG);
	auto test = new LBinop (index, new LRegRead (leftExp, new LConstDecimal (2, LSize.INT, LSize.LONG), LSize.LONG), Tokens.INF);
	inst += new LWrite (index, new LConstDecimal (0, LSize.INT));
	inst += debut;
	inst += new LJump (test, vrai);
	inst += new LGoto (faux);
	vrai.insts += new LWrite (rightExp, new LBinop (leftExp, new LBinop (new LBinop (index, new LConstDecimal (1, LSize.LONG, type.content.size), Tokens.STAR),
									     new LConstDecimal (3, LSize.LONG, LSize.LONG), Tokens.PLUS),
							Tokens.PLUS));
	vrai.insts += block;
	vrai.insts += new LUnop (index, Tokens.DPLUS, true);
	vrai.insts += new LGoto (debut);
	inst += vrai;
	inst += faux;
	return inst;
    }

    /**
     Remplace le block temporaire (mis en place dans InstApplyPreTreat), par le block à appliqué à chaque itération.
     Params:
     func = la boucle itérative.
     block = le block à mettre en place.
     Returns: la liste d'instruction de la boucle final.
     */
    static LInstList InstApply (LInstList func, LInstList block) {
	return func.replace ("tmp_block", block);
    }
    
    /**
     Returns: La liste d'instruction de récupération de l'adresse du tableau.
     */
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList ();
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }
    
}

