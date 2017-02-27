module semantic.pack.Table;
import utils.Singleton, semantic.pack.Symbol;
import semantic.pack.FrameScope, semantic.pack.Scope;
import std.container;

/**
 Cette classe singleton, regroupe toutes les informations sémantique de déclaration de symboles.
 */
class Table {

    /** La liste des scopes de frames en cours d'analyse   */
    private SList!FrameScope _frameTable;

    /** Le scope global du programme */
    private Scope _globalScope;

    /** Le contexte courant */
    private string _namespace;
    
    private this () {
	_globalScope = new Scope ();
    }

    /** 
     On entre dans un nouveau scope     
     */
    void enterBlock () {
	if (!this._frameTable.empty) {
	    this._frameTable.front.enterBlock ();
	}
    }
    
    /**
     On quitte un scope.
     Returns: La liste des symboles à détruire à la fin du scope que l'on vient de quitter
     */
    Array!Symbol quitBlock () {
	if (!this._frameTable.empty) {
	    return this._frameTable.front.quitBlock ();
	} return make!(Array!Symbol);
    }

    /**
     Met à jour le contexte courant.
     Params:
     space = le nom du contexte courant.
     */
    void setCurrentSpace (string space) {
	if (!this._frameTable.empty) 
	    this._frameTable.front ().namespace = space;
	else
	    this._namespace = space;
    }

    /**
     On entre dans une nouvelle frame.
     Params:
     space = le contexte de la frame.
     nbParam = le nombre de paramètre de la frame.
     */
    void enterFrame (string space, ulong nbParam) {
	Symbol.insertLast (nbParam);
	this._frameTable.insertFront (new FrameScope (space));
    }

    /**
     On quitte l'analyse d'une frame.
     Returns: le plus grand identifiant numérique de symboles.
     */
    ulong quitFrame () {
	if (!this._frameTable.empty) {
	    this._frameTable.removeFront ();
	    return Symbol.removeLast ();
	}
	return 0;
    }

    /**
     Returns: le contexte de la frame en cours d'analyse ou celui du programme si aucune frame en cours.
     */
    string namespace() {
	if (this._frameTable.empty) return this._namespace;
	else return this._frameTable.front.namespace;
    }

    /**
     Returns: Le namespace du fichier courant.
     */
    string globalNamespace () {
	return this._namespace;
    }

    /**
     Insert un nouveau symbole dans le scope le plus mince.
     Params:
     info = le symbole à inséré.
     */
    void insert (Symbol info) {
	if (info !is null) info.setId ();
	if (this._frameTable.empty) {
	    _globalScope [info.sym.str] = info;
	} else {
	    this._frameTable.front.insert (info.sym.str, info);
	}
    }

    /**
     Insert un symbole dans le GC du scope le plus mince.
     Params:
     info = le symbole a placer dans le GC.
     */
    void garbage (Symbol info) {
	info.setId ();
	if (!this._frameTable.empty)
	    this._frameTable.front.garbage (info);
	else this._globalScope.garbage (info);
    }

    /**
     Supprime toutes les informations chargé dans la table.
     */
    void purge () {
	this._globalScope.clear ();
	this._frameTable.clear ();
    }

    /**
     Cherche un symbole identifié par x.
     Params:
     name = l'identifiant du symbole.
     Returns: le symbole ou null
     */
    Symbol get (string name) {
	if (this._frameTable.empty) return this._globalScope [name];
	auto ret = this._frameTable.front [name];
	if (ret is null) return this._globalScope [name];
	return ret;
    }

    /**
     Returns: les informations de retour de la frame en cours d'analyse.
     */
    ref FrameReturnInfo retInfo () {
	if (this._frameTable.empty) return FrameReturnInfo.empty;
	else return this._frameTable.front.retInfo ();
    }
    
    mixin Singleton!Table;
}
