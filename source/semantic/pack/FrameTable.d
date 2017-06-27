module semantic.pack.FrameTable;
import utils.Singleton, semantic.pack.Frame;
import std.container, std.algorithm;
import std.array;
import semantic.types.StructInfo;
import semantic.pack.PureFrame;
import semantic.pack.FinalFrame;
import semantic.pack.FrameProto;
import semantic.impl.ObjectInfo;

/**
 Cette classe est un singleton qui contient toutes les instances de frames.
 Elle va permettre l'enregistrement des frames avant leurs transformation en langage intermediaire.
 */
class FrameTable {

    /** Les frames pure présente dans le programme */
    private Array!Frame _pures;

    /** Les frames analysées sémantiquement */
    private Array!FinalFrame _finals;

    /** Les frames analysées sémantiquement résultat de templates */
    private Array!FinalFrame _finalTemplates;
    
    /** Le prototype de frames analysé sémantiquement */
    private Array!FrameProto _protos;

    /** La liste des structures declaré */
    private Array!StructCstInfo _structs;

    /++ La liste des structures qui possède un implémentation +/
    private Array!ObjectCstInfo _objects;
    
    
    /**
     Insertion d'une nouvelle frame pure
     Params:
     frame = la frame a inséré
     */
    void insert (Frame frame) {
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
     Insertion d'une struct
     Params:
     str = la structure
     */
    void insert (StructCstInfo str) {
	this._structs.insertBack (str);
    }    

    /++
     Insertion d'une implementation
     Params:
     obj = l'implementation
     +/
    void insert (ObjectCstInfo obj) {
	auto elem = this._structs [].find!"a is b" (obj.impl);
	if (!elem.empty) {
	    this._structs.linearRemove (elem [0 .. 1]);
	}
	this._objects.insertBack (obj);
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
    bool existProto (ref FrameProto proto) {
	foreach (it ; _protos) {
	    if (it == proto) {
		proto.type = it.type;
		return true;
	    }
	}
	return false;
    }

    StructCstInfo existStruct (string name) {
	foreach (it ; this._structs) {
	    if (it.name == name) return it;
	}
	return null;
    }
    
    /**
     Returns: la liste des structures
     */
    ref Array!StructCstInfo structs () {
	return this._structs;
    }

    /++
     Returns: la liste des objets
     +/
    ref Array!ObjectCstInfo objects () {
	return this._objects;
    }

    /**
     Returns: La liste des frames pures
     */
    ref Array!Frame pures () {
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

