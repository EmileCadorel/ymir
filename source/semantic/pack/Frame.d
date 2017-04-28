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

    protected int _currentScore;
        
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
    
    /**
     Returns: le contexte de la frame 
    */
    ref string namespace () {
	return this._namespace;
    }

    ref int currentScore () {
	return this._currentScore;
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
     Applique un mangling à un string.
     Params:
     name = l'élément à mutiler.
     Returns: la chaine mutilé
     */
    static string mangle (string name) {
	string s = "";
	foreach (it ; name) {
	    if (it == '!')
		s ~= to!string (to!short (it));
	    else if (it == '/')
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

    /**
     Applique une transformation de la frame grâce à des paramètres templates
     Returns: la nouvelle frame ou null
     */
    Frame TempOp (Array!Expression params) {
	return null;
    }
    
}
