module ymir.semantic.types.PtrFuncUtils;
import ymir.semantic._;
import ymir.syntax._;
import ymir.lint._;
import ymir.utils._;
import ymir.ast._;

import std.container;

/**
 Classe regroupant les informations de transformation en langage intermediaire du ptr!function.
 */
class PtrFuncUtils {

    /**
     Affectation d'un pointeur sur fonction.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste des instructions lint.
     */
    static LInstList InstAffect (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += (new LWrite (leftExp, rightExp));
	return inst;
    }

    /**
     Affectation d'un pointeur sur fonction à null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: la liste des instructions lint.
    */
    static LInstList InstAffectNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += (new LWrite (leftExp, new LConstDecimal (0, LSize.LONG)));
	return inst;
    }

    /**
     Test d'egalité entre deux pointeur sur fonctions.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste des instructions lint.
    */
    static LInstList InstIs (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.DEQUAL);
	return inst;
    }

    /**
     Test d'egalité entre un pointeur sur fonction et null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: la liste des instructions lint.
    */
    static LInstList InstIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.DEQUAL);
	return inst;
    }

    /**
     Test d'inegalité entre un pointeur sur fonction et null.
     Params:
     llist = les instructions de l'operande de gauche.
     Returns: la liste des instructions lint.
    */
    static LInstList InstNotIsNull (LInstList llist, LInstList) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst ();
	inst += llist;
	inst += new LBinop (leftExp, new LConstDecimal (0, LSize.LONG), Tokens.NOT_EQUAL);
	return inst;
    }

    /**
     Test d'inegalite entre deux pointeur sur fonction.
     Params:
     llist = les instructions de l'operande de gauche.
     rlist = les instructions de l'operande de droite.
     Returns: la liste des instructions lint.
    */
    static LInstList InstNotIs (LInstList llist, LInstList rlist) {
	auto inst = new LInstList;
	auto leftExp = llist.getFirst (), rightExp = rlist.getFirst ();
	inst += llist + rlist;
	inst += new LBinop (leftExp, rightExp, Tokens.NOT_EQUAL);
	return inst;
    }

    /**
     Créé une constante pointeur sur fonction.
     Params:
     type = le pointeur sur fonction (dont le score à été renseigné à la sémantique).
     Returns: la liste des instructions lint.
    */
    static LInstList InstConstFunc (InfoType type, Expression, Expression) {
	auto inst = new LInstList;
	auto ptr = cast (PtrFuncInfo) type;
	auto leftExp = new LConstFunc (ptr.score.name);
	inst += leftExp;
	return inst;
    }
    

}
