module semantic.pack.Table;
import utils.Singleton, semantic.pack.Symbol;
import semantic.pack.FrameScope, semantic.pack.Scope;
import std.container;
import utils.exception, syntax.Word;

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

    /** La zone est garbage ? */
    private bool _pacified;

    private ulong _nbFrame = 0;
    
    private immutable __maxNbRec__ = 300;
    
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
     On ne garbage plus les données qui sont dans ce block     
     */
    void pacifyMode () {
	this._pacified = true;
    }

    void unpacifyMode () {
	this._pacified = false;
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

    void addCall (Word sym) {
	if (this._nbFrame > __maxNbRec__) {
	    throw new RecursiveExpansion (sym);
	}
    }
    
    /**
     On entre dans une nouvelle frame.
     Params:
     space = le contexte de la frame.
     nbParam = le nombre de paramètre de la frame.
     */
    void enterFrame (string space, ulong nbParam, bool internal) {
	Symbol.insertLast (nbParam);
	this._frameTable.insertFront (new FrameScope (space, internal));
	this._nbFrame ++;
    }

    /**
     On quitte l'analyse d'une frame.
     Returns: le plus grand identifiant numérique de symboles.
     */
    ulong quitFrame () {
	if (!this._frameTable.empty) {
	    this._frameTable.removeFront ();
	    this._nbFrame --;
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
	if (!this._pacified) {
	    info.setId ();
	    if (!this._frameTable.empty)
		this._frameTable.front.garbage (info);
	    else this._globalScope.garbage (info);
	}
    }

    /**
     Retire un symbole dans le GC du scope le plus mince
     Params:
     info = le symbole a retirer dans le GC
     */
    void removeGarbage (Symbol info) {
	if (!this._pacified) {
	    if (!this._frameTable.empty)
		this._frameTable.front.removeGarbage (info);
	    else this._globalScope.removeGarbage (info);
	}
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
	if (ret is null && this._frameTable.front.isInternal) {
	    auto aux = this._frameTable.front;
	    this._frameTable.removeFront ();
	    ret = this._frameTable.front [name];
	    this._frameTable.insertFront (aux);
	    if (ret !is null && !ret.isScoped) ret = null;
	}
	if (ret is null) return this._globalScope [name];
	return ret;
    }

    /++
     Params:
     sym = un symbole
     Returns: Le symbole a été déclarer dans cette frame ?
     +/
    bool sameFrame (Symbol sym) {
	if (this._frameTable.empty) return true;
	auto ret = this._frameTable.front [sym.sym.str];
	if (ret is null) return false;
	return true;
    }
    

    /**
     Cherche tous les symboles dont le nom est presque 'name'
     Params:
     name = le nom du symbole dont on cherche un sosie
     Returns: le sosie ou null
     */
    Symbol getAlike (string name) {
	if (this._frameTable.empty) return this._globalScope.getAlike (name);
	auto ret = this._frameTable.front.getAlike (name);
	if (ret is null) return this._globalScope.getAlike (name);
	return ret;
    }

    /**
     Returns: les informations de retour de la frame en cours d'analyse.
     */
    ref FrameReturnInfo retInfo () {
	if (this._frameTable.empty) return FrameReturnInfo.empty;
	else return this._frameTable.front.retInfo ();
    }

    /**
     Ajoute un fichier importe
     Params:
     name = le nom du fichier importé
     */
    void addImport (string name) {
	if (this._frameTable.empty) this._globalScope.addImport (name);
	else this._frameTable.front.addImport (name);
    }

    /**
     Supprime tous imports reçu
     */
    void clearImport () {
	this._globalScope.clearImport ();
    }

    /**
     On a déja importé ce module ?
     */
    bool wasImported (string name) {
	if (this._frameTable.empty) return this._globalScope.wasImported (name);
	else if (this._frameTable.front.wasImported (name)) return true;
	else if (this._frameTable.front.isInternal) {
	    auto aux = this._frameTable.front;
	    this._frameTable.removeFront ();
	    auto ret = this._frameTable.front.wasImported (name);
	    this._frameTable.insertFront (aux);
	    if (ret) return true;
	}
	return this._globalScope.wasImported (name);
    }

    /** Returns: Le nombre d'appel en cours */
    ulong nbRecursive () {
	return this._nbFrame;
    }

    mixin Singleton!Table;
}
