
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


## Attention
---------------
Les paramètres d'une fonction template ne peuvent pour le moment par être variadics.
Je suis en train de réfléchir à une syntaxe plus clair, pour le permettre.

Très certainement :

```Rust
def foo (T ...) (a : T) {
}

```
