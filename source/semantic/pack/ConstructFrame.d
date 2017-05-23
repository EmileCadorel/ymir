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
    
    this (Namespace namespace, Constructor cst) {
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
	assert (false);
    }
    
    

}



