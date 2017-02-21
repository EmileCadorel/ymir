module semantic.types.RefUtils;
import lint.LInstList, lint.LConst, lint.LRegRead;
import lint.LReg, lint.LWrite, lint.LSysCall;
import std.container, lint.LExp, lint.LBinop;
import syntax.Tokens, lint.LLabel, lint.LGoto, lint.LJump;
import lint.LCast, lint.LSize, semantic.types.ClassUtils;
import semantic.types.ClassUtils, lint.LFrame;
import lint.LCall, lint.LVisitor, semantic.types.InfoType;
import ast.Expression, std.stdio;

/**
 Cette classe regroupe les fonctions nécéssaire à la transformation en lint du type ref.
 */
class RefUtils {

    /**
     Affectation d'une reference.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste d'instruction de l'affectation.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }

    /**
     Application de l'unref automatique de la ref.
     Params:
     size = la taille du contenu.
     llist = les instructions de l'operande à déréférencer.
     Returns: la liste d'instruction de l'unref.
     */
    static LInstList InstUnrefS (LSize size) (LInstList llist) {
	auto leftExp = llist.getFirst ();
	return new LInstList (new LRegRead (leftExp, new LConstDecimal (0, LSize.INT), size));
    }    

    
}
