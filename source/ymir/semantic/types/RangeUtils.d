module ymir.semantic.types.RangeUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;

/**
 Classe contenant les fonctions nécéssaire à la transformation du type range en lint.
 */
class RangeUtils {

    /** Le nom du constructeur de range */
    static string __CstName__ = "_YPCstRange";


    static void createFunctions () {
	createCstRange ();
    }
    
    /++
     + Fonction de construction du type range.
     + Example:
     + ---
     + def cstRange (size : int) {
     +     let ret = alloc (2 * long + 2 * size).as![long];
     +     ret [0] = 1;
     +     ret [1] = $free;
     +     return ret;
     + }
     + ---
     +/
    static void createCstRange () {
	auto last = LReg.lastId;
	LReg.lastId = 0;
	auto size = new LReg (LSize.LONG);
	auto retReg = new LReg (LSize.LONG);
	auto entry = new LLabel (new LInstList), end = new LLabel;
	entry.insts += new LSysCall ("alloc", make!(Array!LExp) ([new LBinop (new LConstDecimal (0, LSize.LONG, LSize.LONG),
									      new LBinop (size, new LConstDecimal (2, LSize.LONG), Tokens.STAR),
									      Tokens.PLUS)]), retReg);

	auto fr = new LFrame (__CstName__, entry, end, retReg, make!(Array!LReg) ([size]));
	LFrame.preCompiled [__CstName__] = fr;
	LReg.lastId = last;
    }

    /**
     Fonction de récupération de l'attribut 'fst'.
     Params: 
     size = la taille du contenu du range.
     llist = les instruction de l'operande.
     Returns: les instructions lint de l'accès.
     */
    static LInstList InstFst (LSize size) (LInstList, LInstList llist) {
	auto leftExp = llist.getFirst ();
	llist += new LRegRead (leftExp, new LConstDecimal (0, LSize.INT, LSize.LONG), size);
	return llist;
    }
    
    /**
     Fonction de récupération de l'attribut 'scd'.
     Params: 
     size = la taille du contenu du range.
     llist = les instruction de l'operande.
     Returns: les instructions lint de l'accès.
     */
    static LInstList InstScd (LSize size) (LInstList, LInstList llist) {
	auto leftExp = llist.getFirst ();
	llist += new LRegRead (leftExp, new LBinop (new LConstDecimal (0, LSize.INT, LSize.LONG),
						    new LConstDecimal (1, LSize.INT, size),
						    Tokens.PLUS),
			       size);
	return llist;
    }

    /**
     Affectation d'un type range, qui n'a jamais été affécté avant.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint de l'affectation.
     */
    static LInstList InstAffectRight (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LWrite (leftExp, rightExp);
	return inst;
    }

    /**
     Destruction d'un objet de type range.
     Params: 
     llist = les instructions de l'operande.
     Returns: les instructions lint de la déstruction.
     */
    static LInstList InstDestruct (LInstList llist) {
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
	return inst;
    }

    /**
     Application de l'operateur 'in' à droite.
     Params:
     size = la taille du type contenu dans le type range.
     llist = la liste d'instruction de l'operande de gauche.
     rlist = la liste d'instruction de l'operande de droite.
     Returns: la liste d'instruction du test.
     */
    static LInstList InstIn (LSize size) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	auto scd = new LRegRead (rightExp, new LBinop (new LConstDecimal (0, LSize.INT, LSize.LONG),
						       new LConstDecimal (1, LSize.INT, size),
						       Tokens.PLUS),
				 size);
	auto fst = new LRegRead (rightExp, new LConstDecimal (0, LSize.INT, LSize.LONG), size);
	inst += new LBinop (new LBinop (leftExp, fst, Tokens.SUP_EQUAL), new LBinop (leftExp, scd, Tokens.INF), Tokens.DAND);
	return inst;
    }

    
    /**
     Création de la liste d'instruction de la boucle d'itération sur un type range.
     Params:
     _type = le type range résultat de l'analyse sémantique, qui contient des informations éssentiel.
     _left = l'expression de type range sur laquelle on itére.
     _right = une ParamList, qui contient les itérateurs à renseigner.
     Returns: une liste d'instruction qui contient un block temporaire que l'on va remplacer par le contenu de la boucle.
     */
    static LInstList InstApplyPreTreat (InfoType _type, Expression _left, Expression _right) {
	auto inst = new LInstList;
	auto type = cast (RangeInfo) _type;
	if (type.value) return InstApplyPreTreatWithValue (type, _left, _right);
	auto left = LVisitor.visitExpressionOutSide (_left);
	for (long nb = _left.info.type.lintInstS.length - 1; nb >= 0; nb --) 
	    left = _left.info.type.lintInst (left, nb);
	    
	auto right = LVisitor.visitExpressionOutSide ((cast (ParamList) _right).params [0]);
	auto leftExp = left.getFirst (), rightExp = right.getFirst ();
	inst += left + right;
	auto debut = new LLabel, vrai = new LLabel (new LInstList), block = new LLabel ("tmp_block");
	auto faux = new LLabel;
	auto fst = new LRegRead (leftExp, new LConstDecimal (0, LSize.INT, LSize.LONG), type.content.size);
	inst += new LWrite (rightExp, fst);
	auto scd = new LRegRead (leftExp, new LBinop (new LConstDecimal (0, LSize.LONG, LSize.LONG),
						      new LConstDecimal (1, LSize.LONG, type.content.size),
						      Tokens.PLUS), type.content.size);
	    
	auto test = new LBinop (rightExp,  scd, Tokens.NOT_EQUAL);
	inst += debut;
	inst += new LJump (test, vrai);
	inst += new LGoto (faux);
	vrai.insts += block;
	auto vrai2 = new LLabel (new LInstList), faux2 = new LLabel (new LInstList);
	vrai.insts += new LJump (new LBinop (fst, scd, Tokens.INF), vrai2);
	vrai.insts += new LGoto (faux2);
	if (type.content.size == LSize.FLOAT || type.content.size == LSize.DOUBLE) {
	    vrai2.insts += new LBinop (rightExp, new LCast (new LConstDouble (1), type.content.size), rightExp, Tokens.PLUS);
	    vrai2.insts += new LGoto (debut);
	    faux2.insts += new LBinop (rightExp, new LCast (new LConstDouble (1.), type.content.size), rightExp, Tokens.MINUS);
	    faux2.insts += new LGoto (debut);
	} else {
	    vrai2.insts += new LUnop (rightExp, Tokens.DPLUS, true);
	    vrai2.insts += new LGoto (debut);
	    faux2.insts += new LUnop (rightExp, Tokens.DMINUS, true);
	    faux2.insts += new LGoto (debut);
	}
	vrai.insts += vrai2;
	vrai.insts += faux2;
	inst += vrai;
	inst += faux;
	return inst;	
    }

    private static LInstList InstApplyPreTreatWithValue (RangeInfo info, Expression _left, Expression _right) {
	auto inst = new LInstList;
	auto val = cast (RangeValue) info.value;
	auto right = LVisitor.visitExpressionOutSide ((cast (ParamList) _right).params [0]);
	auto rightExp = right.getFirst ();
	auto fstL = val.left.toLint (_left.info, info.content), scdL = val.right.toLint (_left.info, info.content);
	auto fst = fstL.getFirst (), scd = scdL.getFirst;
	inst += fstL + scdL + right;
	auto debut = new LLabel, vrai = new LLabel (new LInstList), block = new LLabel ("tmp_block");
	auto faux = new LLabel;
	
	inst += new LWrite (rightExp, fst);
	auto test = new LBinop (rightExp, scd, Tokens.NOT_EQUAL);
	inst += debut;
	inst += new LJump (test, vrai);
	inst += new LGoto (faux);
	vrai.insts += block;
	if ((cast (BoolValue) val.left.BinaryOp (Tokens.INF, val.right)).isTrue) {
	    if (rightExp.size == LSize.FLOAT || rightExp.size == LSize.DOUBLE)
		vrai.insts += new LBinop (rightExp, new LCast (new LConstDouble(1), rightExp.size), rightExp, Tokens.PLUS);
	    else 
		vrai.insts += new LUnop (rightExp, Tokens.DPLUS, true);
	} else {
	    if (rightExp.size == LSize.FLOAT || rightExp.size == LSize.DOUBLE)
		vrai.insts += new LBinop (rightExp, new LCast (new LConstDouble(1), rightExp.size), rightExp, Tokens.MINUS);
	    else 
		vrai.insts += new LUnop (rightExp, Tokens.DMINUS, true);
	}
	
	vrai.insts += new LGoto (debut);
	inst += vrai;
	inst += faux;
	return inst;
    }
    

    /**
     Remplacement du block temporaire par le contenu de la boucle.
     Params:
     func = les instructions de la boucle itérative créées par la fonction InstApplyPreTreat
     block = les instructions contenu dans la boucle.
     Returns: la boucle final.
     */
    static LInstList InstApply (LInstList func, LInstList block) {
	import std.stdio;
	return func.replace ("tmp_block", block);
    }


    
}
