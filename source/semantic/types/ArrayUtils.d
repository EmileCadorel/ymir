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

    static immutable string __CstName__ = "_Y4core5array8cstArrayPFulubZPv";
    
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
	auto expr = llist.getFirst ();
	auto inst = new LInstList;
	inst += llist;
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
	inst += new LRegRead (cast (LExp) leftExp, new LConstDecimal (0, LSize.INT, LSize.LONG), LSize.LONG);
	return inst;
    }

    /**
     Returns: la liste d'instruction de récupération du ptr!char de la string.
     */
    static LInstList InstPtr (LInstList, LInstList list) {
	auto inst = new LInstList;
	auto leftExp = list.getFirst ();
	inst += list;
	inst += new LRegRead (leftExp, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.ULONG);
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
	auto elem = new LBinop (
	    new LRegRead (leftExp, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.ULONG),
	    new LBinop (new LCast (rightExp, LSize.ULONG),
			new LConstDecimal (1, LSize.LONG, size),
			Tokens.STAR),
	    Tokens.PLUS);
	
	inst += new LRegRead (elem, new LConstDecimal (0, LSize.INT), size);	
	return inst;
    }

    static LRegRead InstAccess (LExp left, LExp right, LSize size) {
	auto elem = new LBinop (new LRegRead (left, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.ULONG),
				right,
				Tokens.PLUS);
	
	return new LRegRead (elem, new LConstDecimal (0, LSize.INT), size);
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
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
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
	auto test = new LBinop (index, new LRegRead (leftExp, new LConstDecimal (0, LSize.INT, LSize.LONG), LSize.LONG), Tokens.INF);
	inst += new LWrite (index, new LConstDecimal (0, LSize.INT));
	inst += debut;
	inst += new LJump (test, vrai);
	inst += new LGoto (faux);
	vrai.insts += new LWrite (rightExp, new LBinop (new LRegRead (leftExp, new LConstDecimal (1, LSize.INT, LSize.LONG), LSize.ULONG),
							new LBinop (index, new LConstDecimal (1, LSize.LONG, type.content.size), Tokens.STAR),
							Tokens.PLUS)
	);
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
    

    static LInstList InstAffectRightStatic (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LWrite (leftExp, new LAddr (rightExp));
	return inst;
    }
    

}

