module ymir.semantic.pack.FinalFrame;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;

import std.stdio, std.conv, std.container, std.outbuffer;


/**
 Frame utilisé pour la génération du langage intérmédiaire.
 */
class FinalFrame {

    /** l'indentifiant du type de retour de la frame */
    private Symbol _type;

    /** le fichier de provenance de la frame */
    private string _file;

    /++ L'emplacement de la frame +/
    private Namespace _namespace;
    
    /** le nom de la frame */
    private string _name;

    /** les paramètre de la frame */
    private Array!Var _vars;

    /++ Les templates utilisé pour valider la frame +/
    private Array!Expression _tmps;

    /++ La frame a été crée depuis un spécialisation variadic +/
    private bool _isVariadic;
    
    /** le block de la frame */
    private Block _block;

    /** l'identifiant du dernier symbole */
    private ulong _last;
    
    this (Symbol type, Namespace space, string name, Array!Var vars, Block block, Array!Expression tmps) {
	this._type = type;
	this._vars = vars;
	this._block = block;
	this._name = name;
	this._last = last;
	this._namespace = space;
	this._tmps = tmps;
    }

    /**
     Returns: Le nom de la frame
     */
    string name () {
	return this._name;
    }

    Namespace namespace () {
	return this._namespace;
    }
    
    /** 
     Returns: le fichier dont la frame est issue
     */
    ref string file () {
	return this._file;
    }    
    
    /**
     Returns: le type de retour de la frame
     */
    Symbol type () {
	return this._type;
    }

    /**
     Returns: l'identifiant du dernier symbol de la frame
     */
    ref ulong last () {
	return this._last;
    }

    /++
     Returns: la frame a ete crée depuis une spécialisation variadic ?
     +/
    ref bool isVariadic () {
	return this._isVariadic;
    }
    
    /**
     Returns: la liste des paramètres de la frame
     */
    Array!Var vars () {
	return this._vars;
    }

    Array!Expression tmps () {
	return this._tmps;
    }

    /**
     Returns: le block de la frame
     */
    Block block () {
	return this._block;
    }
}
