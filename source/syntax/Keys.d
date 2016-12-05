module syntax.Keys;
import syntax.Tokens;
import std.typecons;

enum Keys : Token {
    IMPORT = Token ("import", 1),
    CLASS = Token ("class", 2),
    STRUCT = Token ("struct", 3),
    DEF = Token ("def", 4),
    NEW = Token("new", 5),
    DELETE = Token ("delete", 6),
    IF = Token ("if", 7),
    RETURN = Token ("return", 8),
    FOR = Token ("for", 9),
    FOREACH = Token ("foreach", 10),
    WHILE = Token ("while", 11),
    BREAK = Token ("break", 12),
    THROW = Token ("throw", 13),
    TRY = Token ("try", 14),
    SWITCH = Token ("switch", 15),
    DEFAULT = Token ("default", 16),
    IN = Token ("in", 17),
    ELSE = Token ("else", 18),
    CATCH = Token ("catch", 19),
    TRUE = Token ("true", 20),
    FALSE = Token ("false", 21),
    NULL = Token ("null", 22),
    CAST = Token ("cast", 23),
    FUNCTION = Token ("function", 24),
    LET = Token ("let", 25),
    IS = Token ("is", 26),
    NOT_IS = Tokens ("!is", 27),
    ANTI = Token ("\\", 28),
    LX = Token ("x", 29),
    SYSTEM = Token ("system", 30),
    EXTERN = Token ("extern", 31)
}
