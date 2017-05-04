module semantic.pack.FrameScope;
import semantic.pack.Scope, semantic.pack.Symbol;
import semantic.types.InfoType, utils.exception;
import std.container, std.outbuffer, std.string;
import std.stdio, syntax.Word, std.algorithm;

/**
 Cette classe enregistre le informations sur les retour et les break executer dans une frame.
 Ces informations sont structurées sous forme d'arbre
*/
class TreeInfo {

    /** le nom du block identifié */
    private string _name;

    /** l'identifiant de boucle (peut être eof) */
    private Word _ident;

    /** Les blocs enfants */
    private Array!TreeInfo _infos;

    /** Le block contient une instruction de retour*/
    private bool _returned = false;

    /** Le block contient une instruction de break */
    private bool _breaked = false;

    /** Le pere du block courant (peut être null) */
    private TreeInfo _father;
    
    this (string name) {
	this._name = name;
    }

    /** 
     Returns: L'identifiant de boucle 
    */
    Word ident () {
	return this._ident;
    }

    /** 
     Le block s'appele x ou contient un descendant s'appelant x
     Params:
     name = le nom recherché
     Returns: l'identifiant de boucle du noeud recherché, ou eof
     */
    Word exist (string name) {
	if (this._ident.str == name) return this._ident;
	else if (this._father) return this._father.exist (name);
	else return Word.eof;
    }

    /** 
     Met a jour l'identifiant de boucle
     Params: 
     name = le nom à donner au block
     Throws: MultipleLoopName
     */
    void ident (Word name) {
	auto ex = this.exist (name.str);
	if (!ex.isEof ()) throw new MultipleLoopName (name, ex);
	this._ident = name;
    }

    /** 
     Le block contient une instruction de retour
     */
    void returned () {
	this._returned = true;
    }    

    /** 
     Le block contient une instruction de break
     */
    void breaked () {
	this._breaked = true;
    }    

    /**
     Returns: le nom du block
     */
    string name () {
	return this._name;
    }
    
    /** 
     Un nouveau block est declaré
     Params:
     sc = le nom du block
     Returns: le nouveau block créé
     */
    TreeInfo enterBlock (string sc) {
	this._infos.insertBack (new TreeInfo (sc));
	this._infos.back._father = this;
	return this._infos.back;
    }
    
    /**
     Returns: Le block est il cassé ?
     */
    bool hasBreaked () {
	if (this._infos.length == 0) return this._breaked;
	ulong nb = 0;
	string need = "";
	bool allNeed = true;
	foreach (it ; this._infos) {
	    if (!allNeed && need == it._name) allNeed = true;
	    if (it._breaked && it._name == "true") {
		this._breaked = true;
		return true;
	    } else if (it._breaked && it._name == "else") {
		nb ++;
	    } else if (it._breaked && it._name == "if") {
		nb ++;
		allNeed = false;
		need = "else";
	    } else if (it._breaked && it._name != "while" && it._name != "for") {
		nb ++;
	    }
	}
	
	if (nb == this._infos.length && allNeed) {
	    this._breaked = true;
	}
	return this._breaked;    
    }

    /**
     Returns: Le block est il fini ?
     */
    bool hasReturned () {
	if (this._infos.length == 0) return this._returned;
	ulong nb = 0;
	string need = "";
	bool allNeed = true;
	foreach (it ; this._infos) {
	    if (!allNeed && need == it._name) allNeed = true;
	    if (it._returned && it._name == "true") {
		this._returned = true;
		return true;
	    } else if (it._returned && it._name == "else") {
		nb ++;
	    } else if (it._returned && it._name == "if") {
		nb ++;
		allNeed = false;
		need = "else";
	    } else if (it._returned && it._name != "while" && it._name != "for") {
		nb ++;
	    }
	}
	
	if (nb == this._infos.length && allNeed) {
	    this._returned = true;
	}
	return this._returned;
    }

    /** 
     Ferme le block courant
     Returns: le pere du block
     */
    TreeInfo quitBlock () {
	hasBreaked ();
	hasReturned ();
	return this._father;
    }

    /**
     Returns: Recherche parmis tous les fils, le block est il fini ?     
     */
    bool retract () {
	if (this._infos.length == 0) {
	    if (this._father !is null) return this._father.retract ();
	    else return this._returned;
	}	
	hasReturned ();
	if (this._father)
	    return this._father.retract;
	else return this._returned;
    }

    /** 
     Remonte les block jusqu'a l'identifiant de boucle nommé x
     Params:
     name = l'identifiant recherché
     nb = l'offset courant
     Returns: le nombre de block remonté necessaire
     */
    long rewind (string name, long nb = 0) {
	nb ++;
	if (this._ident.str == name) {
	    return nb;
	} else if (this._father) {
	    return this._father.rewind (name, nb);
	} else return -1;
    }

    /** 
     Remonte les block jusqu'a l'identifiant de boucle nommé x
     Params:
     name = les types de block recherchés
     nb = l'offset courant
     Returns: le nombre de block remonté necessaire
    */
    long rewind (string [] types, long nb = 0) {	
	nb ++;
	if (find(types, this._name) != []) return nb;
	else if (this._father) return this._father.rewind (types, nb);
	else return -1;
    }

    /**
     Affiche les informations sous forme d'arbre
     Params:
     i = l'offset courant
     */
    void print (int i = 0) {
	auto buf = new OutBuffer ();
	if (this._returned) 
	    writefln ("%s%s, %s {:true", rightJustify("", i, ' '),
		      this._name, this._ident.str);
	else
	    writefln ("%s%s, %s {", rightJustify("", i, ' '),
		      this._name, this._ident.str);
	
	foreach (it ; this._infos) {
	    it.print (i + 4);
	}
	writefln ("%s}", rightJustify ("", i, ' '));
    }
        
}


/** 
 La table racine qui contient les informations sur les block de retour 
*/
struct FrameReturnInfo {

    /** Le type de retour de la frame courante */
    Symbol info;

    /** Le nom block courant */
    private string _currentBlock;

    /** Le block courant */
    private TreeInfo _retInfo = null;
    
    private bool _changed = false;

    /** Retourne une structure vide */
    static ref FrameReturnInfo empty () {
	return _empty;
    }

    /** 
     Returns: la frame est finis ?
     */
    void returned () {
	this._retInfo.returned;
    }    

    /** 
     Returns: La frame est break
     */
    void breaked () {
	this._retInfo.breaked ();
    }

    ref bool changed () {
	return this._changed;
    }
    
    /** 
     Entre dans un nouveau block
     */
    void enterBlock () {
	if (this._retInfo)
	    this._retInfo = this._retInfo.enterBlock (this._currentBlock);
	else this._retInfo = new TreeInfo (this._currentBlock);
    }

    /** 
     Quitte un block
     */
    void quitBlock () {
	if (!this._retInfo) return;
	this._retInfo = this._retInfo.quitBlock ();
	if (this._retInfo)
	    this._currentBlock = this._retInfo.name;
    }

    /**
     Returns: le block courant est finis ?
     */
    bool retract () {
	if (this._retInfo) 
	    return this._retInfo.retract ();
	return false;
    }

    /** 
     Returns: le block courant contient une instruction de retour ?
     */
    bool hasReturned () {
	if (this._retInfo) 
	    return this._retInfo.hasReturned ();
	else return false;
    }

    /** 
     Returns: le block courant contient une instruction de break ?
    */
    bool hasBreaked () {
	if (this._retInfo)
	    return this._retInfo.hasBreaked ();
	else return false;
    }    

    /** 
     Met  jour l'identifiant de boucle du block courant
     */
    void setIdent (Word ident) {
	this._retInfo.ident = ident;
    }    

    /** 
     Returns: le nom du block courant
     */
    ref string currentBlock () {
	return this._currentBlock;
    }   

    /** 
     Returns: le block courant est stoppé ?
     */
    long rewind (string name) {
	return this._retInfo.rewind (name);
    }

    /** 
     Returns: le block courant est stoppé ?
     */
    long rewind (string [] types) {
	return this._retInfo.rewind (types);
    }

    /** 
     Affiche les informations de block sous forme d'arbre
     */
    void print () {
	this._retInfo.print ();
    }

    static FrameReturnInfo _empty;
}


/**
 Contient les informations sur les symboles contenu dans une frame.
 */
class FrameScope {
    
    /** les informations de retour de la frame */
    private FrameReturnInfo _retInfo;

    /** les sous scope de la frame */
    private SList!Scope _local;

    /** Le contexte de la frame */
    private string _namespace;

    bool _isInternal;
    
    this (string namespace, bool isInternal) {
	this._retInfo.currentBlock = "";
	this._namespace = namespace;
	this._isInternal = isInternal;
	this.enterBlock ();
    }
    
    /**
     On entre dans un nouveau scope
     */
    void enterBlock () {
	this._local.insertFront (new Scope ());
	this._retInfo.enterBlock ();
    }

    
    void addImport (string name) {
	if (!this._local.empty) {
	    this._local.front.addImport (name);	    
	}
    }

    bool wasImported (string name) {
	foreach (it ; this._local) {
	    if (it.wasImported (name)) return true;
	}
	return false;
    }

    ref bool isInternal () {
	return this._isInternal;
    }    
    
    /**
     On quitte le scope
     Returns: la liste des symboles à supprimé dans ce scope
     */
    Array!Symbol quitBlock () {
	this._retInfo.quitBlock ();
	if (!this._local.empty) {
	    auto ret = this._local.front ().quit (this._namespace);
	    this._local.removeFront ();
	    return ret;
	}
	return make!(Array!Symbol);
    }

    /**
     Insert un nouveau symbole dans le dernier scope (ou le met à jour)
     */
    void insert (string name, Symbol info) {
	this._local.front [name] = info;
    }

    /** 
     Insert un nouveau symbol dans la poubelle du dernier scope 
     */
    void garbage (Symbol info) {
	if (!this._local.empty)
	    this._local.front.garbage (info);
    }
    
    /**
     Retire un nouveau symbol dans la poubelle du dernier scope
     */
    void removeGarbage (Symbol info) {
	if (!this._local.empty)
	    this._local.front.removeGarbage (info);
    }
    
    /**
     Params:
     name = le nom du symbole recherché
     Returns: le symbole identifié par `name`
     */
    Symbol opIndex (string name) {
	foreach (it ; this._local) {
	    auto t = it [name];
	    if (t !is null) return t;
	}
	return null;
    }

    /**
     Cherche un symbole dont le nom est presque celui recherche
     Params:
     name = le nom du symbole recherché
     Returns: Le symbole dont le nom est presque 'name'
     */
    Symbol getAlike (string name) {
	foreach (it ; this._local) {
	    auto t = it.getAlike (name);
	    if (t !is null) return t;
	}
	return null;
    }
    
    /**
     Returns: le contexte de la frame
     */
    ref string namespace () {
	return this._namespace;
    }

    /**
     Returns: les informations de retour de la frame
     */
    ref FrameReturnInfo retInfo () {
	return this._retInfo;
    }
    
}
