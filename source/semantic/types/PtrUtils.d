module semantic.types.PtrUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LSize;
import lint.LConst, ast.Constante, syntax.Word;
import lint.LVisitor, semantic.types.InfoType;
import ast.Expression, lint.LAddr;

/**
 Cette classe regroupe les fonctions nécéssaire à la transformation de ptr vers le lint.
 */
class PtrUtils {

    /**
     Affectation d'un pointeur.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }
    
    /**
     Affectation d'un pointeur à null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: les instructions du lint.
     */
    static LInstList InstAffectNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += (new LWrite (leftExp, new LConstDecimal (0, LSize.LONG)));
	return inst;
    }

    /**
     Application d'un opérateur entre deux pointeur..
     Params:
     size = je sais pas.
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOp (LSize size, Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new  LBinop (leftExp, new LCast (rightExp, LSize.ULONG), op));
	return inst;
    }
   
    /**
     Application d'un opérateur entre deux pointeur à droite.
     Params:
     size = je sais pas.
     op = l'operateur.
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: les instructions du lint.
     */
    static LInstList InstOpInv (LSize size, Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new  LBinop (new LCast (rightExp, LSize.ULONG), leftExp, op));
	return inst;
    }

    /**
     Application d'un accés à la valeur pointé.
     Params:
     size = la taille de l'élément pointé.
     llist = les instructions de l'operande.
     Returns: les instructions de l'accés en lint.
     */
    static LInstList InstUnref (LSize size) (LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LRegRead (leftExp, new LConstDecimal (0, LSize.INT), size);
	return inst;
    }

    /**
     Application d'un accés à la valeur pointé, (a partir d'un operateur '.').
     Params:
     size = la taille de l'élément pointé.
     llist = les instructions de l'operande.
     Returns: les instructions de l'accés en lint.     
     */
    static LInstList InstUnrefDot (LSize size) (LInstList, LInstList llist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LRegRead (leftExp, new LConstDecimal (0, LSize.INT), size);
	return inst;
    }

    /**
     Application de l'operateur de test d'egalité.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste d'instruction du test en lint.
     */
    static LInstList InstIs (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.DEQUAL);
	return inst;
    }

    
    /**
     Application de l'operateur de test d'inégalité.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste d'instruction du test en lint.
     */
    static LInstList InstNotIs (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.NOT_EQUAL);
	return inst;
    }

    /**
     Application de l'operateur de test d'inégalité, avec null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: la liste d'instruction du test en lint.
     */
    static LInstList InstNotIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.NOT_EQUAL);
	return inst;
    }

    /**
     Application de l'operateur de test d'égalité, avec null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: la liste d'instruction du test en lint.
    */
    static LInstList InstIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.DEQUAL);
	return inst;
    }

    /**
     Returns: la liste d'instruction de la constante null.
     */
    static LInstList InstNull (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstDecimal (0, LSize.LONG);
	return inst;
    }

    /**
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: la liste d'instruction d'un cast d'un pointeur vers un autre (llist).
     */
    static LInstList InstCast (LInstList llist) {
	return llist;
    }

    /**
     Constante du nom du pointeur.
     Params:
     left = l'expression dont le type est ptr
     Returns: la liste d'instruction qui contient la création de la constante.
     */
    static LInstList GetStringOf (InfoType, Expression left, Expression) {
	auto type = left.info;
	auto inst = new LInstList;
	auto str = new String (Word.eof, type.typeString).expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    /**
     Constante de nom du pointeur (ne fait rien).
     Params:
     left = la liste d'instruction créé par GetStringOf.
     Returns: left.
     */
    static LInstList StringOf (LInstList, LInstList left) {
	return left;
    }

    /**
     L'instruction de récuperation de l'addresse d'un ptr.
     Params:
     llist = la liste d'instruction de l'operande.
     Returns: une liste d'instruction du lint.
     */
    static LInstList InstAddr (LInstList llist) {
	auto inst = new LInstList;
	auto exp = llist.getFirst ();
	inst += llist;
	inst += new LAddr (exp);
	return inst;
    }


    
}


