module semantic.types.FunctionInfo;
import semantic.types.InfoType, utils.exception;
import ast.ParamList, std.container, semantic.pack.UnPureFrame;
import semantic.pack.Frame;
import std.stdio, syntax.Word;

class FunctionInfo : InfoType {

    private string _name;
    private string _namespace;    
    private Array!Frame _infos;
    
    this (string namespace, string name) {
	this._name = name;
	this._namespace = namespace;
    }

    override bool isSame (InfoType) {
	return false;
    }
    
    void insert (Frame fr) {
	this._infos.insertBack (fr);
    }

    override InfoType clone () {
	return this;
    }

    override InfoType cloneForParam () {
	assert (false, "C'est quoi cette histoire, une fonction en parametre");
    }    
    
    ApplicationScore CallOp (Word func_token, Array!InfoType  params) {
	ulong id = 0;
	Array!ApplicationScore total;
	try {
	    foreach (it ; 0 .. this._infos.length)
		total.insertBack (this._infos[it].isApplicable (params));
	    
	    Array!Frame goods;
	    ApplicationScore right = new ApplicationScore;
	    foreach (it ; 0 .. total.length) {
		if (total [it] !is null) {
		    if (goods.length == 0 && total [it].score != 0) {
			right = total[it];
			goods.insertBack (this._infos [it]);
		    } else if (right.score < total [it].score) {
			goods.clear ();
			goods.insertBack (this._infos [it]);
			right = total [it];
		    } else if (right.score == total [it].score && total [it].score != 0) {
			goods.insertBack (this._infos [it]);
		    }
		}
	    }

	    if (goods.length == 0) return null;
	    else if (goods.length != 1)
		throw new TemplateSpecialisation (goods [0].func.ident, goods [1].func.ident);
	    auto info = goods [0].validate (params);
	    right.name = info.name;
	    right.ret = info.type.type.cloneForParam ();
	    return right;
	} catch (YmirException exp) {
	    exp.print ();
	    throw new TemplateCreation (func_token);
	} catch (ErrorOccurs err) {
	    auto a = new TemplateCreation (func_token);
	    a.print ();
	    throw err;
	}	
    }
    
    override ApplicationScore CallOp (Word func_token, ParamList params) {
	ulong id = 0;
	Array!ApplicationScore total;
	try {
	    foreach (it ; 0 .. this._infos.length)
		total.insertBack (this._infos[it].isApplicable (params));
	    
	    Array!Frame goods;
	    ApplicationScore right = new ApplicationScore;
	    foreach (it ; 0 .. total.length) {
		if (total [it] !is null) {
		    if (goods.length == 0 && total [it].score != 0) {
			right = total[it];
			goods.insertBack (this._infos [it]);
		    } else if (right.score < total [it].score) {
			goods.clear ();
			goods.insertBack (this._infos [it]);
			right = total [it];
		    } else if (right.score == total [it].score && total [it].score != 0) {
			goods.insertBack (this._infos [it]);
		    }
		}
	    }

	    if (goods.length == 0) return null;
	    else if (goods.length != 1)
		throw new TemplateSpecialisation (goods [0].func.ident, goods [1].func.ident);
	    auto info = goods [0].validate (params);
	    right.name = info.name;
	    right.ret = info.type.type.cloneForParam ();
	    return right;
	} catch (YmirException exp) {
	    exp.print ();
	    throw new TemplateCreation (func_token);
	} catch (ErrorOccurs err) {
	    auto a = new TemplateCreation (func_token);
	    a.print ();
	    throw err;
	}
	
    }

    override void quit (string namespace) {
	foreach (it; 0 .. this._infos.length) {
	    if (this._infos [it].namespace == namespace) {		
		this._infos.linearRemove (this._infos[it .. it + 1]);
	    }
	}
    }
    
    override string typeString () {
	return "function <" ~ this._namespace ~ "." ~ this._name ~ ">";
    }    

}

