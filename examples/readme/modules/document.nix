''
### Document our module

To documento our modules is simple, we just need to use `config.files.docs` as follow

```nix
# examples/docs.nix

${builtins.readFile ../../docs.nix}
```

<details>
<summary>We could also generate a mdbook with it</summary>
<br>


```nix
# examples/book.nix

${builtins.readFile ../../book.nix}
```


</details>


And publish this mdbook to github pages with `book-as-gh-pages` alias.

''

