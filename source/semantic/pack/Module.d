module semantic.pack.Module;
import semantic.pack.Symbol, semantic.pack.Scope;
import semantic.pack.Namespace;
import std.container;

/**
 Cette classe contient les informations d'un import
 TODO, Elle est a compléter
 */
class Module {

    /** le nom du fichier importé */
    private Namespace _namespace;

    /++ Tout les namespace qui ont le droit d'accéder au module +/
    private Array!Namespace _opens;

    /++ Tout les modules qui ont le droit d'accéder au module depuis un import public. +/
    private Array!Namespace _publicOpen;
    
    /** Le scope global de la frame qui va contenir toutes le declaration importable */
    private Scope _globalScope;

    this (Namespace namespace) {
	this._namespace = namespace;
	this._globalScope = new Scope ();
    }

    /**
     Params:
     name = le nom du symbole recherché
     Returns: le symbol identifié par name
    */    
    Symbol get (string name) {
	return this._globalScope [name];
    }

    /++
     
     +/
    Array!Symbol getAll (string name) {
	return this._globalScope.getAll (name);
    }
    
    /** 
     Insert un nouveau symbol
     Params:
     symbol = le symbole à définir
     */
    void insert (Symbol symbol) {
	this._globalScope [symbol.sym.str] = symbol;
    }

    /++
     Ajoute un namespace qui a le droit d'accéder au module
     +/
    void addOpen (Namespace space) {
	this._opens.insertBack (space);
    }

    /++
     Supprime un namespace qui a le droit d'accéder au module
     +/
    void close (Namespace space) {
	import std.algorithm;
	this._opens.linearRemove (this._opens [].find (space));
    }
    
    /++
     Ajoute un namespace qui à le droit d'accéder au module depuis un import public.
     +/
    void addPublicOpen (Namespace space) {
	this._publicOpen.insertBack (space);
    }

    /++
     Returns: la liste des namespace autorisé à acceder au module.
     +/
    Array!Namespace opens () {
	return this._opens;
    }

    /++
     Returns: la liste des namespace autorisé à acceder au module depuis un import public.
     +/
    Array!Namespace publicOpens () {
	return this._publicOpen;
    }

    /++
     Returns: Le namespace à le droit d'accéder au module ?
     +/
    bool authorized (Namespace space) {
	if (space !is null) {
	    if (this._namespace.isSubOf (space)) return true;
	    foreach (it ; this._opens) {
		if (it.isSubOf (space)) return true;
	    }
	    
	    foreach (it ; this._publicOpen) {
		if (it.isSubOf (space)) return true;
	    }
	}
	return false;
    }
    
    /++
     Le namespace global du module
     +/
    Namespace space () {
	return this._namespace;
    }

}
