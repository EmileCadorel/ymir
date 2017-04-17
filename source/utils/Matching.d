module utils.Matching;
import std.traits;

T match (T, Elem) (Elem e) if (is (T : Elem)) {
    return cast (T) e;
}
