module semantic.pack.FinalFrame;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.InfoType, semantic.pack.FrameScope;


/**
 Frame utilisé pour la génération du langage intérmédiaire.
 */
class FinalFrame {

    /** l'indentifiant du type de retour de la frame */
    private Symbol _type;

    /** le fichier de provenance de la frame */
    private string _file;

    /** le nom de la frame */
    private string _name;

    /** les paramètre de la frame */
    private Array!Var _vars;

    /** les symboles à détruire en sortie de frame */
    private Array!Symbol _dest;

    /** le block de la frame */
    private Block _block;

    /** l'identifiant du dernier symbole */
    private ulong _last;

    private string _unmangleName;
    
    this (Symbol type, string name, string un, Array!Var vars, Block block) {
	this._type = type;
	this._vars = vars;
	this._block = block;
	this._name = name;
	this._last = last;
	import core.demangle, std.conv;
	this._unmangleName = un;
    }

    /**
     Returns: Le nom de la frame
     */
    string name () {
	return this._name;
    }

    string unmangle () {
	return this._unmangleName;
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

    /**
     Returns: la liste des symboles a détruire en fin de frame
     */
    ref Array!Symbol dest () {
	return this._dest;
    }

    /**
     Returns: la liste des paramètres de la frame
     */
    Array!Var vars () {
	return this._vars;
    }

    /**
     Returns: le block de la frame
     */
    Block block () {
	return this._block;
    }
}
