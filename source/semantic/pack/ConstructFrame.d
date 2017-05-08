module semantic.pack.ConstructFrame;
import ast.Class, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.InfoType, semantic.pack.FrameScope;
import semantic.pack.Frame;
import semantic.pack.FrameProto;
import semantic.pack.FinalFrame;
import semantic.types.ClassInfo;
import syntax.Keys;

class ConstructFrame : Frame {

    /** Le prototype du constructeur */
    private FrameProto _fr;

    /** Le constructeur a valider */
    private Constructor _cst;

    /** L'information sur la classe que l'on est en train de construire */
    private ClassCstInfo _info;
    
    private static const string thisName = Keys.NEW.descr;
    
    this (string namespace, Constructor cst) {
	super (namespace, null);
	this._cst = cst;
    }

    override FrameProto validate (ParamList) {
	return this.validate ();
    }

    override FrameProto validate (Array!InfoType) {
	return this.validate ();
    }

    override FrameProto validate () {
	string name = this._namespace ~ to!string (Keys.NEW.descr.length) ~ Keys.NEW.descr;
	Table.instance.enterFrame (name, this._cst.params.length, this._isInternal);
	Table.instance.enterBlock ();

	Array!Var finalParams;
	foreach (it ; 0 .. this._cst.params.length) {
	    auto info = this._function.params [it].expression;
	    finalParams.insertBack (info);
	    finalParams.back ().info.id = it + 1;
	    auto t = finalParams.back ().info.type.simpleTypeString ();
	    name ~= super.mangle (t);
	}

	Table.instance.setCurrentSpace (this._namespace ~ to!string (thisName.length) ~ thisName);
	
	auto proto = FrameTable.instance.existProto (name);
	if (proto is null) {
	    Table.instance.retInfo.info = new Symbol (false, this._cst.token, new VoidInfo ());
	    this._fr = new FrameProto (name, name, Table.instance.retInfo.info, finalParams);
	    
	}
	Table.instance.quitBlock ();
	Table.instance.quitFrame ();
	return proto;
    }
    
    

}



