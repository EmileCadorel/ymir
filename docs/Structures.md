#Structure 

Les Structures permettent de créer de nouveaux types. Leurs instances sont allouées dynamiquement et récupérées par le garbage collector.

Il existe deux syntaxe pour définir les structures:
```D
struct (i : int) A;
struct (f : float, tab : [int]) B;

```

Ou :
```D
struct 
| f : float
| tab : [int]
-> B;
```

Et on les instancie:

```D
let a = A (10), b = B (.1, []);
let b2 = b; // b2 est une reference vers b, aucune recopie n'est faite.

```
L'accès au paramètre se fait avec l'opérateur '_._'

```D
print (a.i);
print (b.f);
print (b.s); // Erreur, la structure B(float) n'a pas d'attribut 's'
b.tab += [10];
```
## Appel

Les attributs des structures sont passés par référence
```D

struct (attr : int) A;

def foo (a : A) {
    a.attr = 123; // les attributs de a sont passé par références
    a = A (2); // a ne sera pas changé en sortie de fonction
}

// ...
let a = A (0);
foo (a);
println (a.attr); // 123
```

## Structure privée

 Il est possible de déclarer des structures dans des blocs, elles deviennent privées à ce bloc.

 ```D
 def test () {}
 def foo () {
     {
        struct (a : int) C;
        struct (a : int, f : float) test; // Erreur, 'test' existe déjà, c'est une fonction
        let a = C (123); // Ok, a est de type 'C'
     }
     let c = C (10); // Erreur, 'C' n'existe pas
 }
 ```




