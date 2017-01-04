module semantic.pack.Frame;
import ast.Function, semantic.pack.Table;
import ast.Var, semantic.types.UndefInfo, semantic.pack.Symbol;
import syntax.Word, ast.Block, semantic.pack.FrameTable;
import std.stdio, std.conv, std.container, std.outbuffer;
import semantic.types.VoidInfo, ast.ParamList;
import utils.exception;
import semantic.types.InfoType, semantic.pack.FrameScope;


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
    protected string _namespace;
    
    static long SAME = 10;
    static long AFF = 5;
    static long CHANGE = 7;
    
    this (string namespace, Function func) {
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
     Fonction à surchagé pour l'analyse sémantique, après appel (spécialement pour les frames templates)
     */    
    FrameProto validate (ParamList params) {
	assert (false);
    }
    
    /**
     Fonction à surchagé pour l'analyse sémantique, après appel (spécialement pour les frames templates)
     */    
    FrameProto validate (Array!InfoType params) {
	assert (false);
    }
    
    /**
     Returns: le contexte de la frame 
    */
    ref string namespace () {
	return this._namespace;
    }

    /**
     Vérifie que la frame s'est bien terminé sur un retour, ou qu'elle de type `void`
     Throws: NoReturnStmt
     */
    void verifyReturn (Word token, Symbol ret, FrameReturnInfo infos) {
	if (!(cast (VoidInfo) ret.type) && !(cast(UndefInfo) ret.type)) {
	    if (!infos.retract) {
		throw new NoReturnStmt (token, ret);
	    }
	}
    }

    /**
     La frame est elle applicable pour l'appel ?
     Params:
     params = les types des paramètres de l'appel.
     Returns: Un score d'application ou null si non applicable.
     */
    ApplicationScore isApplicable (Array!InfoType params) {
	auto score = new ApplicationScore (this._function.ident);
	if (params.length == 0 && this._function.params.length == 0) {
	    score.score = AFF; return score;
	} else if (params.length == this._function.params.length) {
	    foreach (it ; 0 .. params.length) {
		auto param = this._function.params [it];
		InfoType info = null;
		if (cast (TypedVar) param !is null) {
		    info = (cast(TypedVar)param).getType ().clone ();
		    auto type = params [it].CompOp (info);
		    if (type && type.isSame (info)) {
			score.score += SAME;
			score.treat.insertBack (type);
		    } else if (type !is null) {
			score.score += AFF;
			score.treat.insertBack (type);
		    } else return null;

		} else {
		    score.score += CHANGE;
		    score.treat.insertBack (null);
		}
	    }
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
    ApplicationScore isApplicable (ParamList params) {
	auto score = new ApplicationScore (this._function.ident);
	if (params.params.length == 0 && this._function.params.length == 0) {
	    score.score = 10; return score;
	} else if (params.params.length == this._function.params.length) {
	    foreach (it ; 0 .. params.params.length) {
		auto param = this._function.params [it];
		InfoType info = null;
		if (cast (TypedVar) param !is null) {
		    info = (cast(TypedVar)param).getType ().clone ();
		    auto type = params.params [it].info.type.CompOp (info);
		    if (type && type.isSame (info)) {
			score.score += SAME;
			score.treat.insertBack (type);
		    } else if (type !is null) {
			score.score += AFF;
			score.treat.insertBack (type);
		    } else return null;

		} else {
		    score.score += CHANGE;
		    score.treat.insertBack (null);
		}
	    }
	    return score;
	}
	return null;
    }

    /**
     Applique un mangling à un string.
     Params:
     name = l'élément à mutiler.
     Returns: la chaine mutilé
     */
    static string mangle (string name) {
	string s = "";
	foreach (it ; name) {
	    if (it == '/')
		s ~= to!string (to!ushort ('.'));
	    else if ((it < 'a' || it > 'z') && (it < 'A' || it > 'Z')) 
		s ~= to!string(to!short (it));
	    else s ~= it;
	}
	return s;
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
    
}

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
    
    this (Symbol type, string name, Array!Var vars, Block block) {
	this._type = type;
	this._vars = vars;
	this._block = block;
	this._name = name;
	this._last = last;
    }

    /**
     Returns: Le nom de la frame
     */
    string name () {
	return this._name;
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

