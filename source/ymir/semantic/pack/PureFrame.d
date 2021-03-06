module ymir.semantic.pack.PureFrame;
import ymir.ast._;
import ymir.semantic._;
import ymir.syntax._;
import ymir.utils._;
import ymir.compiler._;

import std.stdio, std.conv, std.container, std.outbuffer;

class PureFrame : Frame {

    /** le nom de la frame */
    private string _name;

    /** le prototype de la frame */
    private FrameProto _proto;

    /** la frame à déjà été validé ? */
    private bool valid = false;

    /++ Les paramètres du main on déjà été validé +/
    private bool _pass = false;

    /**
     Params:
     namespace = le contexte de la frame
     func = la fonction associé à la frame
     */
    this (Namespace namespace, Function func) {
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
	if (this._proto) return this._proto;
	if (this._name == Keys.MAIN.descr && !this._pass) return validateMain ();
	Table.instance.enterFrame (this._namespace, this._name, this._function.params.length, this._isInternal);
	Table.instance.enterBlock ();
	
	Array!Var finalParams = super.computeParams (this._function.params);
	this._proto = super.validate (finalParams);
	return this._proto;
    }    

    private FrameProto validateMain () {
	if (this._function.params.length == 1) {
	    auto tok = this._function.params [0].token;
	    if (auto a = cast (TypedVar) this._function.params [0]) {
		auto type = a.getType ();
		if (!type.isSame (new ArrayInfo (true, new StringInfo (true)))) 
		    throw new WrongTypeForMain (this._function.ident);
	    } else {
		auto str = Word (tok.locus, "string", false);
		this._function.params [0] = new TypedVar (tok,
							  new ArrayVar (tok, new Var (str)));		
	    }
	    
	    if (COMPILER.isToLint) {
		auto finalParam = make!(Array!Var) (
		    new TypedVar (Word (tok.locus, "#argc", false),
				  new Var (Word (tok.locus, "int", false))),
		    new TypedVar (Word (tok.locus, "#argv", false),
				  new Var (Word (tok.locus, "p", false),
					   make!(Array!Expression) (
					       new Var (Word (tok.locus, "p", false),
							make!(Array!Expression) (
							    new Var (Word(tok.locus, "char", false)))
					       )
					   )
				  )
		    )
		);
		
		auto blk = this._function.block;
		blk.insts = make!(Array!Instruction) (
		    new VarDecl (tok,
				 make!(Array!Word) (Word (tok.locus, "const", false)),
				 make!(Array!Var) (new Var (tok)),
				 make!(Array!Expression) (
				     new Binary (Word (tok.locus, Tokens.EQUAL.descr, false),
						 new Var (tok),
						 new Par (tok, tok, new Var (Word (tok.locus, "getArgs", false)),
							  new ParamList (tok,
									 make!(Array!Expression) (
									     new Var (Word (tok.locus, "#argc", false)),
									     new Var (Word (tok.locus, "#argv", false))
									 )
							  )
						 )
				     )
				 )
		    )
		) ~ blk.insts;
		
		this._function.params = finalParam;
	    } else {
		auto finalParam = make!(Array!Var) (
		    new TypedVar (tok,
				  new ArrayVar (tok,
						new Var (Word (tok.locus, "string", false)
						)						
				  )
		    )
		);
		this._function.params = finalParam;
	    }
	    
	} else if (this._function.params.length != 0)
	    throw new WrongTypeForMain (this._function.ident);
	
	this._pass = true;
	return validate ();
    }
}
