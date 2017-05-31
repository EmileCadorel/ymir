module syntax.Tokens;
import std.typecons;

struct Token {
    string  descr;
    ulong id;
}

enum Tokens : Token {
    DIV = Token ("/", 0), 
    DIV_AFF = Token("/=", 1),
    DOT = Token (".", 2),
    DDOT = Token ("..", 3),
    TDOT = Token ("...", 4),
    AND = Token ("&", 5),
    AND_AFF = Token ("&=", 6),
    DAND = Token ("&&", 7),
    PIPE = Token ("|", 8),
    PIPE_EQUAL = Token ("|=", 9),
    DPIPE = Token ("||", 10),
    MINUS = Token ("-", 11),
    MINUS_AFF = Token ("-=", 12),
    DMINUS = Token ("--", 13),
    PLUS = Token ("+", 14),
    PLUS_AFF = Token ("+=", 15),
    DPLUS = Token ("++", 16),
    INF = Token ("<", 17),
    INF_EQUAL = Token ("<=", 18),
    LEFTD = Token ("<<", 19),
    LEFTD_AFF = Token ("<<=", 20),
    SUP = Token (">", 21),
    SUP_EQUAL = Token (">=", 22),
    RIGHTD_AFF = Token (">>=", 23),
    RIGHTD = Token (">>", 24),
    NOT = Token ("!", 25),
    NOT_EQUAL = Token ("!=", 26),
    NOT_INF = Token ("!<", 27),
    NOT_INF_EQUAL = Token ("!<=", 28),
    NOT_SUP = Token ("!>", 29),
    NOT_SUP_EQUAL = Token ("!>=", 30),
    LPAR = Token ("(", 31),
    RPAR = Token (")", 32),
    LCRO = Token ("[", 33),
    RCRO = Token ("]", 34),
    LACC = Token ("{", 35),
    RACC = Token ("}", 36),
    INTEG = Token ("?", 37),
    COMA = Token (",", 38),
    SEMI_COLON = Token (";", 39),
    COLON = Token (":", 40),
    DOLLAR = Token ("$", 41),
    EQUAL = Token ("=", 42),
    DEQUAL = Token ("==", 43),
    STAR = Token ("*", 44),
    STAR_EQUAL = Token ("*=", 45),
    PERCENT = Token ("%", 46),
    PERCENT_EQUAL = Token ("%=", 47),
    XOR = Token ("^", 48),
    XOR_EQUAL = Token ("^=", 49),
    DXOR = Token ("^^", 50),
    DXOR_EQUAL = Token ("^^=", 51),
    TILDE = Token ("~", 52),
    TILDE_EQUAL = Token ("~=", 53),
    AT = Token ("@", 54),
    IMPLIQUE = Token ("=>", 55),
    SHARP = Token ("#", 56),
    SPACE = Token (" ", 57),
    RETOUR = Token ("\n", 58),
    RRETOUR = Token ("\r", 59),
    LCOMM1 = Token ("#*", 60),
    RCOMM1 = Token ("*#", 61),
    LCOMM2 = Token ("//", 62),
    GUILL = Token ("\"", 63),
    APOS = Token ("'", 64),
    TAB = Token ("\t", 65),
    LCOMM3 = Token ("/*", 66),
    RCOMM3 = Token ("*/", 67),
    SQRT = Token ("¬", 68),
    ARROW = Token ("->",  69),
    BSTRING = Token ("(_{", 70),
    ESTRING = Token ("}_)", 71),
    DCOLON = Token ("::", 72)
}    


