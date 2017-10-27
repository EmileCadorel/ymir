module ymir.semantic.pack.Table;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;

import std.container;

/**
 Cette classe singleton, regroupe toutes les informations sémantique de déclaration de symboles.
 */
class Table {

    /** La liste des scopes de frames en cours d'analyse   */
    private SList!FrameScope _frameTable;

    /** Le scope global du programme */
    private Scope _globalScope;

    /** Le namespace qui est en train de faire une résolution template */
    private Namespace _templateScope;
    
    /++ Liste des modules importé dans la vie de la compilation +/
    private Array!Module _importation;

    /++ Liste de modules compilé, par nécéssairement importé +/
    private Array!Namespace _foreigns;
    
    /** Le contexte courant */
    private Namespace _namespace;

    /** Le contexte du programme */
    private Namespace _programNamespace;

    private Array!Global _globalVars;
    
    private ulong _nbFrame = 0;
    
    private immutable __maxNbRec__ = 300;

    private Array!(Instruction) _staticInits;
    
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
     */
    void quitBlock () {
	if (!this._frameTable.empty) 
	    this._frameTable.front.quitBlock ();	
    }
    
    /**
     Met à jour le contexte courant.
     Params:
     space = le nom du contexte courant.
     */
    void setCurrentSpace (Namespace namespace, string name) {
	auto space = new Namespace (namespace, name);
	if (!this._frameTable.empty) 
	    this._frameTable.front ().namespace = space;
	else
	    this._namespace = space;	
    }
    
    /**
     Met à jour le contexte courant.
     Params:
     space = le nom du contexte courant.
     */
    void resetCurrentSpace (Namespace space) {
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

    void addGlobal (Global gl) {
	this._globalVars.insertBack (gl);
    }

    Array!Global globalVars () {
	return this._globalVars;
    }
    
    /**
     On entre dans une nouvelle frame.
     Params:
     space = le contexte de la frame.
     nbParam = le nombre de paramètre de la frame.
     */
    void enterFrame (Namespace space, string name, ulong nbParam, bool internal) {
	Symbol.insertLast (nbParam);
	this._frameTable.insertFront (new FrameScope (new Namespace (space, name), internal));
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
    Namespace namespace() {
	if (this._frameTable.empty) return this._namespace;
	else return this._frameTable.front.namespace;
    }

    /**
     Returns: Le namespace du fichier courant.
     */
    Namespace globalNamespace () {
	return this._namespace;
    }

    ref Namespace programNamespace () {
	return this._programNamespace;
    }

    /++
     Returns: la namespace qui est en train de faire une résolution template
     +/
    ref Namespace templateScope () {
	return this._templateScope;
    }
    
    /**
     Insert un nouveau symbole dans le scope le plus mince.
     Params:
     info = le symbole à insérer.
     */
    void insert (Symbol info) {
	if (this._frameTable.empty) {
	    _globalScope [info.sym.str] = info;
	} else {
	    this._frameTable.front.insert (info.sym.str, info);
	}
    }

    /++
     Ajoute une instruction a executé en debut de programme
     Params:
     exp = l'Instruction à executé
     +/
    void addStaticInit (Instruction exp) {
	this._staticInits.insertBack (exp);
    }

    /++
     La liste des instructions a éffectué en tout début de programme.
     +/
    Array!Instruction staticInits () {
	return this._staticInits;
    }
    
    /**
     Supprime toutes les informations chargé dans la table.
     */
    void purge () {
	this._globalScope.clear ();
	this._frameTable.clear ();
	this._staticInits.clear ();
	this._globalVars.clear ();
	ExternFrame.clear ();
    }

    /**
     Cherche un symbole identifié par x.
     Params:
     name = l'identifiant du symbole.
     Returns: le symbole ou null
     */
    Symbol get (string name) {
	import std.stdio;
	Symbol ret;
	Namespace last = this.namespace;
	if (!this._frameTable.empty) {
	    ret = this._frameTable.front () [name];
	    if (ret) return ret;	    
	    
	    foreach (it ; this._frameTable) {
		if (it.namespace.isAbsSubOf (last)) {
		    ret = it [name];
		    if (ret && ret.isScoped) return ret;
		    else ret = null;
		    last = it.namespace;
		} else if (this.namespace != last) break;
	    }
	}
	

	if (ret is null) ret = this._globalScope [name];	
	if (ret is null) {
	    auto mods = getAllMod (this.namespace ());
	    foreach (it ; mods) {
		ret = it.get (name);
		if (ret !is null) return ret;
	    }
	}

	return ret;
    }    

    /**
     Cherche un symbole identifié par x.
     Params:
     name = l'identifiant du symbole.
     Returns: la liste des symboles du même nom ou null
     */
    Array!Symbol getAll (string name) {
	Array!Symbol alls;
	Namespace last = this.namespace;
	if (!this._frameTable.empty) {
	    alls ~= this._frameTable.front ().getAll (name);
	    
	    foreach (it ; this._frameTable) {	    
		if (it.namespace.isAbsSubOf (last)) {
		    auto aux = it.getAll (name);
		    foreach (at ; aux)
			if (at.isScoped) alls.insertBack (at);
		    last = it.namespace;
		} else if (this.namespace != last) break;
	    }
	}
	
	alls ~= this._globalScope.getAll (name);
	auto mods = getAllMod (this.namespace ());
	foreach (it ; mods) {
	    if (!it.space ().isSubOf (this._namespace))
		alls ~= it.getAll (name);
	}
	return alls;
    }

    
    /**
     Cherche un symbole identifié par x.
     Params:
     name = l'identifiant du symbole.
     Returns: le symbole ou null
     */
    Symbol getLocal (string name) {
	Symbol ret;
	Namespace last = this.namespace;
	if (!this._frameTable.empty) {
	    ret = this._frameTable.front () [name];
	    if (ret) return ret;
	    
	    foreach (it ; this._frameTable) {	    
		if (it.namespace.isAbsSubOf (last)) {
		    ret = it [name];
		    if (ret && ret.isScoped) return ret;
		    else ret = null;
		    last = it.namespace;
		} else if (this.namespace != last) break;
	    }
	}
	
	if (ret is null) ret = this._globalScope [name];
	if (ret is null) {
	    auto mods = getAllMod (this.namespace ());
	    foreach (it ; mods) {
		if (!it.space.isSubOf (this.namespace ())) {
		    ret = it.get (name);
		    if (ret !is null) return ret;
		}
	    }
	}
	return ret;
    }

    Symbol local (string name) {
	Symbol ret;
	Namespace last = this.namespace;
	if (!this._frameTable.empty) {
	    ret = this._frameTable.front () [name];
	    if (ret) return ret;
	    
	    foreach (it ; this._frameTable) {	    
		if (it.namespace.isAbsSubOf (last)) {
		    ret = it [name];
		    if (ret && ret.isScoped) return ret;
		    else ret = null;
		    last = it.namespace;
		} else if (this.namespace != last) break;
	    }
	}
	
	if (ret is null) ret = this._globalScope [name];
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
	foreach (it ; this._frameTable) {
	    if (it.namespace.isSubOf (this.namespace ())) {
		auto ret = it.getAlike (name);
		if (ret) return ret;
	    }
	}
	return this._globalScope.getAlike (name);
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
     name = le namespace du module importé
     Returns: un nouveau module à remplir
     */
    Module addModule (Namespace space) {
	auto mod = new Module (space);
	this._importation.insertBack (mod);
	return mod;
    }    

    /++
     Ajoute un module (non utilisable)
     Params:
     name = le namespace du module
     +/
    void addForeignModule (Namespace space) {
	foreach (it ; this._foreigns) {
	    if (space.isSubOf (it)) {
		throw new NamespaceConflict (space);
	    } else if (it.isSubOf (space)) {
		throw new NamespaceConflict (it);
	    }
	}	
	this._foreigns.insertBack (space);
    }
    
    /++
     Retourne la liste des modules autorisé au namespace
     Params:
     space = le namespace qui à des accés.
     Returns: la liste des accès disponible pour le module.
     +/
    Array!Module getAllMod (Namespace space) {
	Array!Module alls;
	foreach (it ; this._importation) {
	    if (it.authorized (space) || it.authorized (this._templateScope)) {
		alls.insertBack (it);
	    }
	}
       	
	return alls;
    }
    
    /++
     Ouvre le module de namespace from pour le module de namespace to.
     Params:
     from = le namspace qui va être ouvert
     to = le namespace qui va obtenir l'accés
     +/
    void openModuleForSpace (Namespace from, Namespace to) {
	Array!Namespace dones;

	void openModuleForSpace (Namespace from, Namespace to, Array!Namespace dones) {    
	    foreach (it ; this._importation) {
		if (it.space == from) {
		    dones.insertBack (it.space);
		    it.addOpen (to);
		    if (!this._frameTable.empty) this._frameTable.front.addOpen (it.space);
		    foreach (mt ; it.publicOpens) {
			dones.insertBack (mt);
			openModuleForSpace (mt, to, dones);
		    }
		    
		    break;
		}
	    }
	}
	
	openModuleForSpace (from, to, dones);
    }


    /++
     Ferme le module pour le namespace
     Params:
     from = le namespace qui va fermer le scope
     to = le namespace qui va perdre l'accés.     
     +/
    void closeModuleForSpace (Namespace from, Namespace to) {
	foreach (it ; this._importation) {
	    if (it.space == from) {
		it.close (to);
		break;
	    }
	}
    }

    /++ 
     La liste des modules connu de la table des symbole.
     Returns: les namespaces de chacun des modules.
     +/
    Array!Namespace modules () {
	Array!Namespace spaces;
	foreach (it ; this._importation) {
	    spaces.insertBack (it.space);
	}
	return spaces;
    }    

    /++ 
     La liste des modules connu de la table des symbole.
     Returns: les namespaces de chacun des modules.
     +/
    Array!Namespace modulesAndForeigns () {
	Array!Namespace spaces;
	foreach (it ; this._importation) {
	    spaces.insertBack (it.space);
	}

	foreach (it ; this._foreigns)
	    spaces.insertBack (it);
	
	return spaces;
    }    

    
    /**
     On a déja importé ce module ?
     */
    bool moduleExists (Namespace name) {	
	foreach (it ; this._importation) {
	    if (it.space == name) return true;
	}
	return false;
    }

    /** Returns: Le nombre d'appel en cours */
    ulong nbRecursive () {
	return this._nbFrame;
    }

    mixin Singleton!Table;
}
