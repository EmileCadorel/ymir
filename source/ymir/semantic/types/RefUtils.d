module ymir.semantic.types.RefUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container, std.stdio;

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
	auto inst = new LInstList;
	inst += llist;
	inst += new LRegRead (leftExp, new LConstDecimal (0, LSize.INT), size);
	return inst;
    }    

    static LInstList InstUnref (LInstList, LInstList llist) {
	return llist;
    }
    
    
}
