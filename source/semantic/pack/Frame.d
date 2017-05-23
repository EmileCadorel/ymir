module semantic.pack.Frame;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.RefInfo;
import semantic.types.InfoType, semantic.pack.FrameScope;
import semantic.pack.FrameProto;
import semantic.types.FunctionInfo;
import semantic.types.StructInfo;
import ast.Expression;
import syntax.Keys;
public import semantic.pack.Namespace;
import semantic.pack.FinalFrame;

/**
 Ancêtre de tout les types de frame:
 <table>
 <li> Pure </li>
 <li> UnPure </li>
 <li> Extern </li>
 </table>
 */
class Frame {

    /** La fonction associé à la frame */
    protected Function _function;

    /** le contexte de la frame */
    protected Namespace _namespace;
    
    static long SAME = 10;
    static long AFF = 5;
    static long CHANGE = 7;

    protected int _currentScore;
        
    protected bool _isInternal = false;

    /**
     Les premiers paramètre templates;
     */
    protected Array!Expression _tempParams;

    
    this (Namespace namespace, Function func) {
	this._function = func;
	this._namespace = namespace;
    }

    /**
     Fonction à surchagé pour l'analyse sémantique
     */
    FrameProto validate () {
	assert (false);
    }

    /**
     Fonction à surchagé pour l'analyse sémantique, après appel (spécialement pour les frames impure)
     */    
    FrameProto validate (ParamList params) {
	assert (false);
    }
    
    /**
     Fonction à surchagé pour l'analyse sémantique, après appel (spécialement pour les frames impoure)
     */    
    FrameProto validate (Array!InfoType params) {
	assert (false);
    }

    /**
     Fonction a surchargé pour l'analyse sémantique, après appel (spécialement pour les frames template)
     */
    FrameProto validate (ApplicationScore score, Array!InfoType params) {
	if (score.tmps.length == 0)
	    return validate (params);
	assert (false);
    }

    static Array!Var computeParams (Array!Var attr, Array!InfoType params) {
	Array!Var finalParams;
	foreach (it ; 0 .. attr.length) {
	    if (cast(TypedVar)attr [it] is null) {
		auto var = attr [it].setType (params [it]);   
		finalParams.insertBack (var.expression);
	    } else {
		finalParams.insertBack (attr [it].expression);
	    }
	    finalParams.back ().info.id = it + 1;
	}
	return finalParams;
    }

    
    static Array!Var computeParams (Array!Var params) {
	Array!Var finalParams;
	foreach (it ; 0 .. params.length) {
	    auto info = params [it].expression;
	    finalParams.insertBack (info);
	    finalParams.back.info.id = it + 1;
	}
	return finalParams;
    }
    

    /++
     Valide la frame
     Params:
     ret = le type de retour
     les paramètre finaux de la frame.
     +/
    static FrameProto validate (Word name, Namespace namespace, Symbol ret, Array!Var finalParams, Block block, Array!Expression tmps) {
	Table.instance.setCurrentSpace (namespace, name.str);
	if (ret is null)
	    Table.instance.retInfo.info = new Symbol (false, Word.eof, new UndefInfo ());
	else
	    Table.instance.retInfo.info = ret;
	
	auto proto = new FrameProto (name.str, namespace, Table.instance.retInfo.info, finalParams, tmps);
	if (!FrameTable.instance.existProto (proto)) {
	    FrameTable.instance.insert (proto);
	    Table.instance.retInfo.currentBlock = "true";
	    block = block.block ();
	    if (cast (UndefInfo) (Table.instance.retInfo.info.type) !is null)
		Table.instance.retInfo.info.type = new VoidInfo ();
	    
	    auto finFrame = new FinalFrame (Table.instance.retInfo.info,
					    namespace, name.str,
					    finalParams, block, tmps);
	    
	    proto.type = Table.instance.retInfo.info;
	    FrameTable.instance.insert (finFrame);
	    
	    finFrame.file = name.locus.file;
	    finFrame.dest = Table.instance.quitBlock ();
	    verifyReturn (name, proto.type, Table.instance.retInfo);
	    finFrame.last = Table.instance.quitFrame ();
	    return proto;
	}
	Table.instance.quitBlock ();
	Table.instance.quitFrame ();
	return proto;	
    }

    protected final FrameProto validate (Array!Var finalParams) {
	Table.instance.setCurrentSpace (this._namespace, this._function.name);
	if (this._function.type is null)
	    Table.instance.retInfo.info = new Symbol (false, Word.eof, new UndefInfo ());
	else 
	    Table.instance.retInfo.info = this._function.type.asType ().info;	
		
	auto proto = new FrameProto (this._function.name, this._namespace, Table.instance.retInfo.info, finalParams, this._tempParams);
	
	if (!FrameTable.instance.existProto (proto)) {
	    FrameTable.instance.insert (proto);
	    Table.instance.retInfo.currentBlock = "true";
	    auto block = this._function.block.block ();
	    
	    if (cast (UndefInfo) (Table.instance.retInfo.info.type) !is null)
		Table.instance.retInfo.info.type = new VoidInfo ();
	    
	    auto finFrame = new FinalFrame (Table.instance.retInfo.info,
					    this._namespace, this._function.name,
					    finalParams, block, this._tempParams);
	    
	    proto.type = Table.instance.retInfo.info;
	    FrameTable.instance.insert (finFrame);
	    
	    finFrame.file = this._function.ident.locus.file;
	    finFrame.dest = Table.instance.quitBlock ();
	    verifyReturn (this._function.ident, proto.type, Table.instance.retInfo);
	    finFrame.last = Table.instance.quitFrame ();
	    return proto;
	}
	Table.instance.quitBlock ();
	Table.instance.quitFrame ();
	return proto;	
    }

    
    protected final FrameProto validate (Namespace space, Array!Var finalParams) {
	Table.instance.setCurrentSpace (space, this._function.name);
	if (this._function.type is null)
	    Table.instance.retInfo.info = new Symbol (false, Word.eof, new UndefInfo ());
	else 
	    Table.instance.retInfo.info = this._function.type.asType ().info;	
		
	auto proto = new FrameProto (this._function.name, space, Table.instance.retInfo.info, finalParams, this._tempParams);
	
	if (!FrameTable.instance.existProto (proto)) {
	    FrameTable.instance.insert (proto);
	    Table.instance.retInfo.currentBlock = "true";
	    auto block = this._function.block.block ();
	    
	    if (cast (UndefInfo) (Table.instance.retInfo.info.type) !is null)
		Table.instance.retInfo.info.type = new VoidInfo ();
	    
	    auto finFrame = new FinalFrame (Table.instance.retInfo.info,
					    space, this._function.name,
					    finalParams, block, this._tempParams);
	    
	    proto.type = Table.instance.retInfo.info;
	    FrameTable.instance.insert (finFrame);
	    
	    finFrame.file = this._function.ident.locus.file;
	    finFrame.dest = Table.instance.quitBlock ();
	    verifyReturn (this._function.ident, proto.type, Table.instance.retInfo);
	    finFrame.last = Table.instance.quitFrame ();
	    return proto;
	}
	Table.instance.quitBlock ();
	Table.instance.quitFrame ();
	return proto;	
    }

    
    /**
     Returns: le contexte de la frame 
    */
    ref Namespace namespace () {
	return this._namespace;
    }

    ref int currentScore () {
	return this._currentScore;
    }

    ref bool isInternal () {
	return this._isInternal;
    }
    
    /**
     Vérifie que la frame s'est bien terminé sur un retour, ou qu'elle de type `void`
     Throws: NoReturnStmt
     */
    static void verifyReturn (Word token, Symbol ret, FrameReturnInfo infos) {
	if (!(cast (VoidInfo) ret.type) && !(cast(UndefInfo) ret.type)) {
	    if (!infos.retract) {
		throw new NoReturnStmt (token, ret);
	    }
	}
    }

    /**
     La frame est elle applicable pour l'appel ?
     Params:
     attrs = les paramètres de la fonction appelé
     args = les types utilisés pour l'appel
     */
    protected ApplicationScore isApplicable (Word ident, Array!Var attrs, Array!InfoType args) {
	auto score = new ApplicationScore (ident);
	if (attrs.length == 0 && args.length == 0) {
	    score.score = AFF;
	    score.score += this._currentScore;
	    return score;
	} else if (attrs.length == args.length) {
	    foreach (it ; 0 .. args.length) {
		InfoType info = null;
		auto param = attrs [it];
		if (cast (TypedVar) param !is null) {
		    info = (cast(TypedVar) param).getType ().clone ();
		    auto type = args [it].CompOp (info);
		    if (type && type.isSame (info)) {
			score.score += SAME;
			score.treat.insertBack (type);
		    } else if (type !is null) {
			score.score += AFF;
			score.treat.insertBack (type);
		    } else return null;
		} else {
		    if (cast (FunctionInfo) args [it] || cast (StructCstInfo) args [it]) return null;
		    auto var = cast (Var) attrs [it];
		    if (var.deco == Keys.REF) {
			auto type = args [it].CompOp (new RefInfo (args [it].clone ()));
			if (type is null) return null;
			score.treat.insertBack (type);
		    } else
			score.treat.insertBack (args[it].clone ());
		    score.score += CHANGE;
		}
	    }
	    score.score += this._currentScore;
	    return score;
	}
	return null;
    }
    
    
    /**
     La frame est elle applicable pour l'appel ?
     Params:
     params = les types des paramètres de l'appel.
     Returns: Un score d'application ou null si non applicable.
     */
    ApplicationScore isApplicable (Array!InfoType params) {
	return this.isApplicable (this._function.ident, this._function.params, params);
    }

    
    /**
     La frame est elle applicable pour l'appel ?
     Params:
     params = les types des paramètres de l'appel.
     Returns: Un score d'application ou null si non applicable.
     */
    ApplicationScore isApplicable (ParamList params) {
	return this.isApplicable (this._function.ident, this._function.params, params.paramTypes);
    }

    /**
     Returns: la fonction associé à la frame
     */
    Function func () {
	return this._function;
    }

    /**
     Returns: l'identifiant de la frame.
     */
    Word ident () {
	return this._function.ident;
    }

    /**
     Applique une transformation de la frame grâce à des paramètres templates
     Returns: la nouvelle frame ou null
     */
    Frame TempOp (Array!Expression params) {
	return null;
    }

    /**
       Returns: Le prototype de la fonction formaté
     */
    string protoString () {
	auto buf = new OutBuffer ();
	buf.writef("def %s.%s ", this._namespace, this._function.name);
	if (!this._function.tmps.empty) {
	    if (this._function.test) 
		buf.writef ("if (%s) ", this._function.test.prettyPrint);	    
	    buf.writef ("(");
	    foreach (it ; this._function.tmps) {
		buf.writef ("%s", it.prettyPrint);
		if (it !is this._function.tmps [$ - 1])
		    buf.writef (", ");
	    }
	    buf.writef (")");
	}
	buf.writef ("(");
	foreach (it ; this._function.params) {
	    buf.writef ("%s", it.prettyPrint);
	    if (it !is this._function.params [$ - 1])
		buf.writef (", ");
	}
	buf.writef (")");
	if (this._function.type) {
	    buf.writef (" : %s",this._function.type.prettyPrint);
	}
	return buf.toString ();
    }
    
}
