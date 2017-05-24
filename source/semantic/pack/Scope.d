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

    /** Les symboles à détruire en fin de scope */
    Array!Symbol _garbage;    
    
    Array!string _imports;

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
    
    void addImport (string name) {
	this._imports.insertBack (name);
    }

    bool wasImported (string name) {
	foreach (it ; this._imports)
	    if (it == name) return true;
	return false;
    }

    void clearImport () {
	this._imports.clear ();
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
	Array!(Symbol) [string] aux;
	this._local = aux;
	this._garbage.clear ();
    }    

    /**
     Quitte le scope, informe les symboles locaux.
     Params:
     namespace = le contexte que l'on est en train de quitter
     Returns: La liste des symboles a détruire
     */
    Array!Symbol quit (Namespace namespace) {
	foreach (key, value; this._local) {
	    foreach (it; value)
		it.quit (namespace);
	}
	return this._garbage;
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
