module semantic.types.CharUtils;
import ast.Expression, lint.LWrite, lint.LInstList;
import lint.LBinop, syntax.Tokens, lint.LSize;
import lint.LExp, lint.LReg, lint.LCast;
import semantic.types.CharInfo, lint.LVisitor;
import syntax.Word, ast.Constante;
import lint.LConst;

/**
 Cette classe regroupe toutes les fonctions nécéssaire à la transformation du type char en lint.
*/
class CharUtils {

    /**
     Affectation de deux élément de type char.
     Params:
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	LInstList inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }

    /**
     Opérateur entre deux type char.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOp (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    /**
     Opérateur entre un type char à gauche et un type int à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.BYTE), op));
	return inst;
    }

    /**
     Opérateur entre un type int à gauche et un type char à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.BYTE), rightExp, op));
	return inst;
    }

    
    /**
     Opérateur d'affectation d'un type char.
     Example:
     ------
     a += b;
     ------
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpAff (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, leftExp, op));
	return inst;
    }


    /**
     Opérateur d'affectation d'un type char avec un int à droite.
     Example:
     ---
     a += b;
     ---
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.
     */
    static LInstList InstOpAffInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.BYTE), leftExp, op));
	return inst;
    }


    /**
     Opérateur de test entre deux type char.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.     
     */
    static LInstList InstOpTest (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, rightExp, op));
	return inst;
    }

    /**
     Opérateur de test entre un type char à gauche et un type int à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.     
     */
    static LInstList InstOpTestInt (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (new LCast (leftExp, LSize.INT), rightExp, op));
	return inst;
    }
    
    /**
     Opérateur de test entre un type int à gauche et un type char à droite.
     Params:
     op = l'operateur à appliquer.
     llist = les instructions de l'operande gauche.
     rlist = les instructions de l'operande droite.
     Returns: la liste d'instruction lint.     
     */
    static LInstList InstOpTestIntRight (Tokens op) (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LBinop (leftExp, new LCast (rightExp, LSize.INT), op));
	return inst;
    }

    
    /**
     La constante d'init d'un char.
     Returns: la liste d'instruction lint.
     */
    static LInstList CharInit (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstByte (0);
	return inst;
    }

    /**
     La constante de taille d'un char.
     Returns: la liste d'instruction lint.
    */    
    static LInstList CharSizeOf (LInstList, LInstList) {
	auto inst = new LInstList;
	inst += new LConstDWord (1, CharInfo.sizeOf);
	return inst;
    }
    
    /**
     La constante de nom d'un char non constant.
     TODO supprimer ces fonctions et faire comme pour bool.
     Returns: la liste d'instruction lint.
    */    
    static LInstList CharStringOf (LInstList, LInstList) {
	auto inst = new LInstList;
	auto str = new String (Word.eof, "char").expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    /**
     La constante de nom d'un char constant.
     TODO supprimer ces fonctions et faire comme pour bool.
     Returns: la liste d'instruction lint.
    */    
    static LInstList CharStringOfConst (LInstList, LInstList) {
	auto inst = new LInstList;
	auto str = new String (Word.eof, "const (char)").expression;
	str.info.type.setDestruct (null);
	inst += LVisitor.visitExpressionOutSide (str);
	return inst;
    }

    static LInstList InstCastInt (LInstList llist) {
	auto inst = new LInstList;
	auto left = llist.getFirst;
	inst += llist;
	inst += new LCast (left, LSize.INT);
	return inst;
    }
    

}
