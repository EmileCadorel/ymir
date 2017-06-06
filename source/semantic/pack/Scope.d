module semantic.pack.Scope;
import semantic.pack.Symbol;
import semantic.pack.Namespace;

import std.container, std.outbuffer, std.string;
import std.algorithm;


/**
 Cette classe permet la déclaration de symbole dans un block sémantique.
 */
class Scope {

    /**  Les symbole déclaré localement */
    Array!(Symbol) [string] _local;

    /++ La table des modules importés +/
    Array!Namespace _imports;

    this () {}

    /**
     Params:
     name = le nom du symbole recherché
     Returns: Le symbole identifié par name ou null
     */
    Symbol opIndex (string name) {
	auto it = (name in this._local);
	if (it !is null) return (*it) [0];
	else return null;
    }

    Array!Symbol getAll (string name) {
	auto it = (name in this._local);
	if (it !is null) {
	    return *it;
	} else return make!(Array!Symbol);
    }

    /++
     Ajoute un import dans la table des import locaux.
     Params:
     space = le namespace du module.
     +/
    void addOpen (Namespace space) {
	this._imports.insertBack (space);
    }
    
    /**
     Recherche un symbole dont le nom est presque 'name'
     Params:
     name = le nom du symbole 
     */
    Symbol getAlike (string name) {
	import std.algorithm;
	auto min = 3UL;
	Symbol ret = null;
	foreach (key, value ; this._local) {
	    auto diff = levenshteinDistance (key, name);
	    if (diff < min) {
		ret = value [0];
		min = diff;
	    }
	}
	return ret;
    }
    
    /**
     Met a jour le symbole identifié par name
     Params:
     data = le symbole à inséré
     name = l'identifiant du symbole
     */
    void opIndexAssign (Symbol data, string name) {
	auto it = name in this._local;
	if (it) 
	    it.insertBack (data);
	else 
	    this._local [name] = make!(Array!Symbol) (data);
    }

    /**
     Efface toutes les informations du scope
     */
    void clear () {
	Array!(Symbol) [string] aux;
	this._local = aux;
    }    

    /**
     Quitte le scope, informe les symboles locaux.
     Params:
     namespace = le contexte que l'on est en train de quitter
     Returns: La liste des symboles a détruire
     */
    void quit (Namespace namespace) {
	import semantic.pack.Table;
	import std.stdio;
	
	foreach (key, value; this._local) {
	    foreach (it; value)
		it.quit (namespace);
	}

	foreach (space ; this._imports) {		
	    Table.instance.closeModuleForSpace (space, namespace);
	}
    }

    override string toString () {
	import std.outbuffer;
	auto buf = new OutBuffer () ;
	buf.write ("{");
	foreach (key, value ; this._local) {
	    buf.writef ("\t%s => {%d}", key, value.length);
	    //foreach (it ; value)
	    //	buf.writef ("%s,", it.type.typeString);
	}
	buf.write ("}");
	return buf.toString;
    }
    
}
