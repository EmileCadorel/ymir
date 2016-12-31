module semantic.pack.FrameTable;
import utils.Singleton, semantic.pack.Frame;
import std.container, std.algorithm;

/**
 Cette classe est un singleton qui contient toutes les instances de frames.
 Elle va permettre l'enregistrement des frames avant leurs transformation en langage intermediaire.
 */
class FrameTable {

    /** Les frames pure présente dans le programme */
    private Array!PureFrame _pures;

    /** Les frames analysé sémantiquement */
    private Array!FinalFrame _finals;

    /** Le prototype de frames analysé sémantiquement */
    private Array!FrameProto _protos;

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
    
    mixin Singleton!FrameTable;    
}

