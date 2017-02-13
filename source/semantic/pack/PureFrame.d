module semantic.pack.PureFrame;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.InfoType, semantic.pack.FrameScope;
import semantic.pack.Frame;
import semantic.pack.FrameProto;
import semantic.pack.FinalFrame;


class PureFrame : Frame {

    /** le nom de la frame */
    private string _name;

    /** le prototype de la frame */
    private FrameProto _fr;

    /** la frame à déjà été validé ? */
    private bool valid = false;

    /**
     Params:
     namespace = le contexte de la frame
     func = la fonction associé à la frame
     */
    this (string namespace, Function func) {
	super (namespace, func);
	if (func)
	    this._name = func.ident.str;
    }


    override ApplicationScore isApplicable (ParamList params) {
	if (params.length > this._function.params.length) return this.isApplicableVariadic (params);
	else return super.isApplicable (params);
	
    }

    override ApplicationScore isApplicable (Array!InfoType params) {
	if (params.length > this._function.params.length) return this.isApplicableVariadic (params);
	else return super.isApplicable (params);
    }

    private ApplicationScore isApplicableVariadic (ParamList params) {
	return null;
    }

    private ApplicationScore isApplicableVariadic (Array!InfoType params) {
	return null;
    }
    
    
    /**
     Analyse sémantique de la frame.
     Returns: le prototype de la frame, avec son nom définitif
     */
    override FrameProto validate (ParamList) {
	return this.validate ();
    }

    /**
     Analyse sémantique de la frame.
     Returns: le prototype de la frame, avec son nom définitif
     */
    override FrameProto validate (Array!InfoType) {
	return this.validate ();
    }

    /** 
     Analyse sémantique de la frame.
     Returns: le prototype de la frame, avec son nom définitif
     */
    override FrameProto validate () {
	if (!valid) {
	    valid = true;
	    string name = this._name;
	    if (this._name != "main") {
		name = this._namespace ~ to!string (this._name.length) ~ this._name;
		name = "_YN" ~ to!string (name.length) ~ name;
	    }
	    
	    Table.instance.enterFrame (name, this._function.params.length);
	    Table.instance.enterBlock ();
	    
	    Array!Var finalParams;
	    foreach (it ; 0 .. this._function.params.length) {
		auto info = this._function.params [it].expression;
		finalParams.insertBack (info);
		finalParams.back ().info.id = it + 1;
		auto t = finalParams.back ().info.type.simpleTypeString ();
		if (name != "main")
		    name ~= super.mangle (t);
	    }

	    Table.instance.setCurrentSpace (this._namespace ~ to!string (this._name.length) ~ this._name);	    	    
	
	    if (this._function.type is null) {
		Table.instance.retInfo.info = new Symbol (false, Word.eof (), new UndefInfo ());
	    } else {
		Table.instance.retInfo.info = this._function.type.asType ().info;
	    }
	    
	    this._fr = new FrameProto (name, Table.instance.retInfo.info, finalParams);
	    Table.instance.retInfo.currentBlock = "true";
	    auto block = this._function.block.block ();
	    if (cast(UndefInfo) (Table.instance.retInfo.info.type) !is null) {
		Table.instance.retInfo.info.type = new VoidInfo ();
	    }

	    auto finFrame =  new FinalFrame (Table.instance.retInfo.info,
				       name,
				       finalParams, block);
	    
	    this._fr.type = Table.instance.retInfo.info;
	    
	    FrameTable.instance.insert (finFrame);	
	    FrameTable.instance.insert (this._fr);

	    finFrame.file = this._function.ident.locus.file;
	    finFrame.dest = Table.instance.quitBlock ();
	    super.verifyReturn (this._function.ident,
				this._fr.type,
				Table.instance.retInfo);
	    
	    finFrame.last = Table.instance.quitFrame ();
	    return this._fr;
	}
	return this._fr;
    }    
    
}

