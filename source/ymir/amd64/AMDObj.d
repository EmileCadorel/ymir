module ymir.amd64.AMDObj;
import ymir.amd64.AMDSize, ymir.target.TExp;

abstract class AMDObj : TExp {
    
    abstract AMDSize sizeAmd ();    
}
