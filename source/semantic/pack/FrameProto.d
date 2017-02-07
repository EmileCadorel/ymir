module semantic.pack.FrameProto;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.InfoType, semantic.pack.FrameScope;



/**
 Classe contenant un prototype de frame.
 Généré à l'analyse sémantique
 */
class FrameProto {

    /** Le nom de la frame */
    private string _name;

    /** Le type de retour de la frame */
    private Symbol _type;

    /** Les paramètres de la frame */
    private Array!Var _vars;

    this (string name, Symbol type, Array!Var params) {
	this._name = name;
	this._type = type;
	this._vars = params;
    }


    /**
     Returns: le nom de la frame
     */
    ref string name () {
	return this._name;	
    }

    /**
     Returns: le type de retour de la frame
     */
    ref Symbol type () {
	return this._type;
    }

    /**
     Returns: La liste de paramètres de la frame
     */
    ref Array!Var vars () {
	return this._vars;
    }       
}

