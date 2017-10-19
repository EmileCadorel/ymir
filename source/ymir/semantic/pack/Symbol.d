module ymir.semantic.pack.Symbol;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;

import std.container;
import std.stdio;

/**
 Cette classe contient les informations de type d'un symbole.
 */
class Symbol {

    /** L'identifiant numérique du symbole (pour la transformation en lint) */
    private ulong _id = 0;

    /** A été déclaré dans la frame parent mais est accessible par scope */
    private bool _scoped;

    /++ Ce symbole est public et peut sortir d'un module ? +/
    private bool _public;

    /** L'identifiant du symbole */
    private Word _sym;

    /** Le type du symbole */
    private InfoType _type;

    /** La liste des identifiants numérique de symbole (par frame) */
    private static SList!ulong __last__;

    /++ La liste des identifiants numérique de symbole statique +/
    private static ulong __lastStatic__ = 0;
    
    private bool _isStatic;
    
    /**
     Params:
     word = l'identifiant du symbole
     type = le type du symbole
     */
    this (Word word, InfoType type) {
	this._sym = word;
	this._type = type;
	setId ();
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
	setId ();
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
	return this._isStatic;
    }

    void isStatic (bool val) {
	this._isStatic = val;
	if (val) setStaticId ();
    }

    bool isType () {
	if (this._type)
	    return this._type.isType;
	return false;
    }

    bool isScoped () {
	return this._type.isScopable;
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
     Returns: le nom du type sous forme de string (avec informations - const ...)
     */
    string typeString () {
	if (this._type.isConst) {
	    auto name = this._type.typeString;
	    if (name.length < 6 || name [0 .. 6] != "const(")
		return "const(" ~ this._type.typeString ~ ")";	    
	}
	return this._type.typeString;
	    
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

    /++
     Returns: Ce symbole est public et peut sortir du module ?
     +/
    ref bool isPublic () {
	return this._public;
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

    void setStaticId () {
	this._id = __lastStatic__ + 1;
	__lastStatic__ ++;
    }
    
    /**
     Génére un clone du symbole mais de manière scopé
     */
    Symbol cloneScoped () {
	auto other = new Symbol (this._sym, this._type.clone (), this.isConst);
	other._scoped = true;
	other._id = this._id;
	return other;
    }
    
}
