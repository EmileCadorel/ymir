module semantic.pack.Scope;
import semantic.pack.Symbol;

import std.container, std.outbuffer, std.string;
import std.algorithm;


/**
 Cette classe permet la déclaration de symbole dans un block sémantique.
 */
class Scope {

    /**  Les symbole déclaré localement */
    Symbol [string] _local;

    /** Les symboles à détruire en fin de scope */
    Array!Symbol _garbage;    
    
    this () {}

    /**
     Params:
     name = le nom du symbole recherché
     Returns: Le symbole identifié par name ou null
     */
    Symbol opIndex (string name) {
	auto it = (name in this._local);
	if (it !is null) return *it;
	else return null;
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
		ret = value;
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
	this._local [name] = data;
    }

    /**
     Insert un symbole dans la liste des symboles destructible
     Params:
     info = le symbole destructible, à détruire en fin de scope
     */
    void garbage (Symbol info) {
	foreach (it ; this._garbage)
	    if (it.id == info.id) return;
	this._garbage.insertBack (info);
    }

    /**
     Retire un symbole dans la liste des symboles destructible
     Params:
     info = le symbole destructible, à retirer de la poubelle
     */
    void removeGarbage (Symbol info) {
	Array!Symbol sym;
	foreach (it ; this._garbage)
	    if (it.id != info.id) sym.insertBack (it);
	this._garbage = sym;
    }
    
    /**
     Efface toutes les informations du scope
     */
    void clear () {
	this._local.clear ();
	this._garbage.clear ();
    }    

    /**
     Quitte le scope, informe les symboles locaux.
     Params:
     namespace = le contexte que l'on est en train de quitter
     Returns: La liste des symboles a détruire
     */
    Array!Symbol quit (string namespace) {
	foreach (key, value; this._local) {
	    value.quit (namespace);
	}
	return this._garbage;
    }

}
