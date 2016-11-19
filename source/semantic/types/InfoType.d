module semantic.types.InfoType;
import syntax.Word, ast.Expression, utils.YmirException;
import std.outbuffer, utils.exception;
import semantic.types.IntInfo, semantic.types.BoolInfo;
import semantic.types.CharInfo, semantic.types.StringInfo;
import semantic.types.FloatInfo, utils.exception;
import lint.LInstList, std.container;
import semantic.pack.UnPureFrame, ast.ParamList;

alias LInstList function (LInstList, LInstList) InstComp;
alias LInstList function (LInstList) InstCompS;
alias Expression function (Expression) InstPreTreatment;

class ApplicationScore {

    this () {
	this.score = 0;
    }

    long score;
    string name;
    InfoType ret;
    Array!InstPreTreatment treat;	
}

class InfoType {

    private InstPreTreatment _leftTreatment = null;
    private InstPreTreatment _rightTreatment = null;
    private InstComp _lintInst = null;
    private InstCompS _lintInstS = null;
    
    static InfoType function (Word, Expression[]) [string] creators;

    static this () {
	creators = ["int" : &IntInfo.create,
		    "bool" : &BoolInfo.create,
		    "string" : &StringInfo.create,
		    "float" : &FloatInfo.create,
		    "char" : &CharInfo.create];
    }    
    
    static InfoType factory (Word word, Expression [] templates) {
	auto it = (word.str in creators);
	if (it !is null) return (*it) (word, templates);
	throw new UndefinedType (word);
    }
    
    int size () {
	return 0;
    }
    
    static bool exist (string name) {
	return (name in creators) !is null;
    }

    string typeString () {
	return "";
    }

    InfoType BinaryOp (Word token, Expression right) {
	return null;
    }

    InfoType BinaryOpRight (Word token, Expression left) {
	return null;
    }

    ApplicationScore CallOp (Word, ParamList) {
	return null;
    }
    
    InfoType CastOp (InfoType) {
	return null;
    }
    
    InfoType clone () {
	return null;
    }

    ref InstPreTreatment leftTreatment () {
	return this._leftTreatment;
    }

    Expression leftTreatment (Expression elem) {
	return this._leftTreatment (elem);
    }
    
    ref InstPreTreatment rightTreatment () {
	return this._rightTreatment;
    }

    Expression rightTreatment (Expression elem) {
	return this._rightTreatment (elem);
    }

    ref InstComp lintInst () {
	return this._lintInst;
    }
       
    LInstList lintInst (LInstList left, LInstList right) {
	return this._lintInst (left, right);
    }

    LInstList lintInst (LInstList left) {
	return this._lintInstS (left);
    }
    
}
