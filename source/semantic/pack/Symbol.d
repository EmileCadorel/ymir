module semantic.pack.Symbol;
import syntax.Word;
import semantic.types.InfoType, semantic.pack.Table;
import std.container, lint.LInstList, lint.LReg;
import std.stdio;
import semantic.value.Value;
import semantic.pack.Namespace;

/**
 Cette classe contient les informations de type d'un symbole.
 */
class Symbol {

    /** L'identifiant numérique du symbole (pour la transformation en lint) */
    private ulong _id = 0;

    /** A été déclaré dans la frame parent mais est accessible par scope */
    private bool _scoped;
    
    /** L'identifiant du symbole */
    private Word _sym;

    /** Le type du symbole */
    private InfoType _type;

    /** La liste des identifiants numérique de symbole (par frame) */
    private static SList!ulong __last__;

    /** Le type va être envoyé dans le GC */
    private bool _garbage;

    private Value _staticValue;
    
    /**
     Params:
     word = l'identifiant du symbole
     type = le type du symbole
     */
    this (Word word, InfoType type) {
	this._sym = word;
	this._type = type;
	if (this._type.isGarbaged) {
	    Table.instance.garbage (this);
	    this._garbage = true;
	} else this._garbage = false;
    }

    /** 
     Params:
     word = l'identifiant du symbole
     type = le type du symbole
     isConst = le symbole est il constant ?
     */
    this (Word word, InfoType type, bool isConst) {
	this._sym = word;
	this._type = type;
	this._type.isConst = isConst;
	if (this._type.isGarbaged) {
	    Table.instance.garbage (this);
	    this._garbage = true;
	} else this._garbage = false;
    }

    /**
     Params:
     garbage = le symbole doit il aller dans le GC ?
     word = l'identifiant du symbole
     type = le type du symbole
     isConst = le symbole est il constant ?
     */
    this (bool garbage, Word word, InfoType type, bool isConst) {
	this._sym = word;
	this._type = type;
	this._type.isConst = isConst;
	if (garbage)
	    Table.instance.garbage (this);
	this._garbage = garbage;
    }

    /**
     Params:
     garbage = le symbole doit il aller dans le GC ?
     word = l'identifiant du symbole
     type = le type du symbole
     */
    this (bool garbage, Word word, InfoType type) {
	this._sym = word;
	this._type = type;
	if (garbage)
	    Table.instance.garbage (this);
	this._garbage = garbage;
    }

    /**
     Returns: Le symbole est il un symbole à placer dans le GC ?
     */
    bool isDestructible () {
	if (this._type !is null) return this._type.isDestructible ();
	return false;
    }

    /**
     Returns: le symbol est il envoyé dans le GC
     */
    bool isGarbage () {
	return this._garbage;
    }
    
    /**
     Returns: Le type du symbole
     */
    ref InfoType type () {
	return this._type;
    }

    /**
     Returns: Le symbole est il constant ?
     */
    ref bool isConst () {
	return this._type.isConst;
    }

    bool isStatic () {
	return this._staticValue !is null;
    }

    bool isType () {
	if (this._type)
	    return this._type.isType;
	return false;
    }

    ref bool isScoped () {
	return this._scoped;
    }
    
    ref Value staticValue () {
	return this._staticValue;
    }

    /**
     Returns: La valeur contenu dans l'objet (si immutable, sinon null)
     */
    ref Value value () {
	return this._type.value;
    }

    /**
     Returns: la valeur du type peut être déduite à l'execution ?
     */
    bool isImmutable () {
	return this._type.value !is null;
    }
    
    /**
     Informe le type que l'on quitte un scope (important pour les déclaration privé type fonction).
     Params:
     namespace = le contexte que l'on quitte
     */
    void quit (Namespace namespace) {
	this._type.quit (namespace);
    }

    /**
     Returns: La transformation en langage intermediaire de la destruction du symbole.     
     */
    LInstList destruct () {
	auto type = this._type.destruct ();
	if (type && type.destruct) {
	    LInstList list = new LInstList (new LReg (this._id, this._type.size));
	    return type.destruct (list);
	}
	
	return new LInstList ();
    }

    /**
     Returns: le nom du type sous forme de string (avec informations - const ...)
     */
    string typeString () {
	if (this._type.isConst) {
	    return "const(" ~ this._type.typeString ~ ")";
	} else return this._type.typeString;
	    
    }

    /**
     Returns: l'identifiant du symbole
     */
    ref Word sym () {
	return this._sym;
    }

    /**
     Returns: le dernier identifiant numérique de symbole
     */
    static ulong lastId () {
	if (__last__.empty) __last__.insertFront (1);
	return __last__.front();
    }

    /**
     Returns: l'identifiant numérique du symbole
     */
    ref ulong id () {
	setId ();
	return this._id;
    }	

    /**
     Informe les identifiant numérique que x symboles on déjà été déclarés.
     Params:
     nbParam = le nombre de paramètre de la frame
     */
    static void insertLast (ulong nbParam) {
	__last__.insertFront (nbParam + 1);
    }

    /**
     Supprime les informations d'identifiant numérique de la dernière frame.
     Returns: le dernier identifiant numérique (celui qui a été supprimé)
     */
    static ulong removeLast () {
	if (!__last__.empty) {
	    auto last = __last__.front ();
	    __last__.removeFront ();
	    return last;
	}
	return 0;
    }

    /**
     Charge l'identifiant numérique du symbole, en fonction des informations numérique de la frame.
     */
    void setId () {
	if (this._id == 0) {
	    if (__last__.empty) __last__.insertFront (1);
	    this._id = __last__.front ();
	    __last__.front ()++;
	}
    }

    /**
     Génére un clone du symbole mais de manière scopé
     */
    Symbol cloneScoped () {
	auto other = new Symbol (false, this._sym, this._type.clone (), this.isConst);
	other._scoped = true;
	other._id = this._id;
	return other;
    }
    
}
