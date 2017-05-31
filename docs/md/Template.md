
# Fonction template
<hr>

Les fonctions templates sont des fonctions impure dont on stocke l'inférence de type dans une variable d'alias.
En d'autre terme, elle sont instancié comme les fonction impures, mais on peut récupérer facilement les types des paramètres et faire une spécialisation de templates plus avancée.



## Déclaration
<hr>

La déclaration de fonctions templates est la suivante :
```Rust
def foo (T) (a : T) {
	println (T.typeid, '(', a, ')');
}

// ...

foo (10); // Ok, const (int)(10)
foo ('salut'); // Ok, const (string) ('salut');
```

Contrairement aux apparences, ce système apporte quelque chose au système de spécialisation de fonction que l'on utilisait avec les fonctions impures.
En effet, il est maintenant possible de spécialiser un type interne d'un autre type (type template par exemple).


```Rust
def foo (T) (a : [T]) {
	println ('fst');
}

def foo (a : [ulong]) {
	println ('scd');
}

//...
foo ([1, 2, 3]); // Ok, 'fst'
foo ([1ul, 2ul]); // Ok, 'scd'

```

## Spécialisation
--------------------

### Spécialisation par constante

Il est possible de passer des expressions comme paramètres templates, ces expressions doivent être évaluées à la compilation. 

```Rust
def test (i : int) (a : int) {
	println (i + a);
}

def test (s : string) () {
	if (s == "123")
		println (s);
}

test!10 (11); // Ok, '21'
test!"123"(); // Ok, '123'
test!"10" (); // Ok
test!'r' (); // Erreur, Aucune surcharge disponible

```

### Spécialisation par décomposition

Le mot clé `of` permet de tester le type d'un paramètre template.

```Rust

def foo (T of int) (a : T) {
}

foo (10); // Ok
foo ("salut") // Erreur

```

Le mot clé `of` permet également de décomposer un type sur ces paramètre templates.

```Rust 

def foo (T of tuple!(U), U) (a : T) {
}

let a = (1,);
let b = (a.0, "salut");

foo (a); // Ok
foo (b); // Erreur

```

Il permet aussi de spécialiser les tableaux.

```Rust 

def foo (T of [U], U) (a : T) {
	println ("Tableau de ", U.typeid);
}

def foo (T of [U], U) (a : T, b : U) {
	println ("Tableau de ", U.typeid, " avec ", b);
}

def foo (T) (a : T) {
	println ("Scalaire ", T.typeid);
}

foo ([1, 2]); // Ok "Tableau de int"
foo (["salut", "hehe"]); // Ok, "Tableau de string"
foo ([1, 2], 3); // Ok, "Tableau de int avec 3"
foo ([1, 2], 'r') // Erreur
foo ('r'); // Ok, "Scalaire char"

```

## Pré-spécialisation
---------------------

On peut forcer l'utilisation d'un type comme paramètre template, grâce à une pré-spécialisation.

```Rust

// On ne peut pas appeler la fonction sans connaître T et U
def foo (T of [U], U) (a : int) {	
}

foo (12); // Erreur
foo!([int]) (12); // Ok

```

Il n'est pas obligatoire de mettre tout les types dans la pré-spécilisation, si les types restants peuvent être inférés grâce aux paramètres.

```Rust 

def foo (T, U) (a : U) : T {
	return T.init;
}

def foo (a : string, U) (b : U) {
	println (a, ' ', b);
}

foo!int (12.3); // Ok, T est de type int, et U de type float
foo!"Bonjour" ("Bob"); // Ok a = Bonjour et U est de type string

```

## Variables statiques
--------------------

Les variables statiques présentent dans les fonctions templates sont communes à chaque spécialisation.

```Rust 

def foo (C : string) () {
	let static a = 0;
	a += 1;
	println (a);
}

foo!"a" (); // Ok, 1
foo!"b" (); // Ok, 2
foo!"c" (); // Ok, 3

```

## Attention
---------------
Les paramètres d'une fonction template ne peuvent pour le moment par être variadics.
Je suis en train de réfléchir à une syntaxe plus clair, pour le permettre.

Très certainement :

```Rust
def foo (T ...) (a : T) {
}

```
