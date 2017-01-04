module semantic.pack.FrameTable;
import utils.Singleton, semantic.pack.Frame;
import std.container, std.algorithm;
import std.array;

/**
 Cette classe est un singleton qui contient toutes les instances de frames.
 Elle va permettre l'enregistrement des frames avant leurs transformation en langage intermediaire.
 */
class FrameTable {

    /** Les frames pure présente dans le programme */
    private Array!PureFrame _pures;

    /** Les frames analysées sémantiquement */
    private Array!FinalFrame _finals;


    /** Les frames analysées sémantiquement résultat de templates */
    private Array!FinalFrame _finalTemplates;
    
    /** Le prototype de frames analysé sémantiquement */
    private Array!FrameProto _protos;

    /** La liste des fichiers déjà importé */
    private Array!string _imported;

    /**
     Ajoute un fichier importe
     Params:
     name = le nom du fichier importé
     */
    void addImport (string name) {
	this._imported.insertBack (name);
    }

    /**
     Returns: le fichier a t'il été importé ?
     */
    bool wasImported (string name) {
	return find (this._imported.array, name) != [];
    }
    
    void clearImport () {
	this._imported.clear ();
    }

    /**
     Insertion d'une nouvelle frame pure
     Params:
     frame = la frame a inséré
     */
    void insert (PureFrame frame) {
	this._pures.insertBack (frame);
    }

    /**
     Insertion d'un frame analysée sémantiquement
     Params:
     frame = la frame analysée
     */
    void insert (FinalFrame frame) {
	this._finals.insertBack (frame);
    }


    /**
     Insertion d'une frame analysée sémantiquement résultat d'un template.
     Params:
     frame = la frame analysée.
     */
    void insertTemplate (FinalFrame frame) {
	this._finalTemplates.insertBack (frame);
    }
    
    /**
     Insertion d'un nouveau prototype de frame
     Params:
     proto = le prototype de frame
     */
    void insert (FrameProto proto) {
	this._protos.insertBack (proto);
    }    

    /**
     Existe t'il une frame analysée sémantiquement de nom x ?
     Params:
     name = le nom de la frame recherchée
     */
    FinalFrame existFinal (string name) {
	foreach (it ; _finals) {
	    if (it.name == name) return it;
	}
	
	foreach (it ; this._finalTemplates) {
	    if (it.name == name) return it;
	}
	
	return null;
    }

    /**
     Existe t'il un prototype de fonction de nom x ?
     Params:
     name = le nom du prototype recherché
     */
    FrameProto existProto (string name) {
	foreach (it ; _protos) {
	    if (it.name == name) return it;
	}
	return null;
    }

    /**
     Returns: La liste des frames pures
     */
    ref Array!PureFrame pures () {
	return this._pures;
    }

    /**
     Returns: La liste des frames analysée sémantiquement
     */
    ref Array!FinalFrame finals () {
	return this._finals;
    }    

    /**
     Returns: la liste des frames analysée sémantiquement résultat de template.
     */
    ref Array!FinalFrame templates () {
	return this._finalTemplates;
    }
    
    mixin Singleton!FrameTable;    
}

