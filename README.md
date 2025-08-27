# LayerLens

Keep your code well structured.

[![package:layerlens](https://img.shields.io/pub/v/layerlens.svg)](https://pub.dev/packages/layerlens)

## What is LayerLens?

LayerLens is a tool that:

1. Automatically generates a dependency diagram as a
[Mermaid `flowchart`](https://mermaid.js.org/syntax/flowchart.html)
within every directory of your Dart or Flutter package.

2. Identifies and alerts you to any cyclic dependencies.

NOTE: LayerLens shows inside-package dependencies. For cross-package dependencies use `flutter pub deps`.

## How does it work?

Unlike other dependency visualization and cycle detection tools that focus on language-specific concepts,
LayerLens innovates by operating on **file system concepts**. It assumes that organizing our code by **files
and directories** we accurately reflect our **mental model* of the project.

Specifically, LayerLens:

1. Restricts each diagram to the content of a single directory,
so that every directory has its own diagram.

3. For each directory treats immediate sub-directories and files as equal elements,
and shows dependencies between these elements as a directed graph.

As result:

1. Each directory diagram is simple. It does not contain (1) any internal details of directories or files, and (2)
any details of code outside the directory.

2. All diagrams together are enough to detect cycles in application.

<img width="536" alt="Screenshot 2023-01-14 at 9 45 33 PM" src="https://user-images.githubusercontent.com/12115586/212524921-5221785f-692d-4464-a230-0f620434e2c5.png">

## Configure layerlens

### Globally

1. Run `dart pub global activate layerlens`

2. Verify you can run `layerlens`. If you get `command not found`, make sure
   your path [contains pub cache](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).

### As a dependency

1. Add `layerlens: <version>` to the section `dev_dependencies` in the package's pubspec.yaml.

2. Run `dart pub get` or `flutter pub get` for the package.

3. Verify you can run `dart run layerlens`.

## Configure IDE

To see the diagrams in your IDE:

- **VSCode**: install `Markdown Preview Mermaid Support` extension

- **Android Studio**: enable the "Mermaid" extension in the
  [Markdown language settings](https://www.jetbrains.com/help/idea/markdown-reference.html)

## Generate diagrams

1. Run command:

   - With global configuration: `layerlens` in the root of the package or
   in other place with `--path <your package root>`

   - With package configuration: `dart run layerlens` in the package root

2. Find the generated file DEPS.md in each source folder, where
   libraries or folders depend on each other.

3. In VSCode, right click DEPS.md and select 'Open Preview'

## Continuous integration

### Fail if issues

Make your pre-submit bots failing in case of issues, using flags:

* `--fail-on-cycles`: fail if there are dependency cycles
* `--fail-if-changed`: fail if the generated diagrams has changed

### Re-generate on every GitHub push

Copy the content of [run-layerlens.yaml](https://github.com/polina-c/layerlens/blob/main/.github/doc/run-layerlens.yaml)
   to `.github/workflows`.

It will work if your repo policy allows bots to update files.

## Filter

If you want to generate the `DEPS.md` only for a specific folders, use `--only` and `--except` options,
formatted as [glob](https://pub.dev/packages/glob) syntax.

For example, to generate the diagrams:

* only for the root `lib/` folder: `dart run layerlens --only "lib"`
* only for the root `lib/` folder: `dart run layerlens --only "lib"`
* for all folders except `l10n/`: `dart run layerlens --except "l10n"`
* only for root `lib/` and it's subfolder: run `layerlens --only "lib" --only "lib/subfolder1"`
* for the entire subtree for a given subfolder: `layerlens --only "lib/subfolder1" --only "lib/subfolder1/**"`

## Supported languages

While layerlens concepts are language agnostic, for now only `dart` is supported.
Please [submit an issue](https://github.com/polina-c/layerlens/issues/new), if you want other language to be added.

## Contribute to layerlens

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details.

## License

Apache 2.0; see [`LICENSE`](LICENSE) for details.

## Disclaimer

This project is not an official Google project. It is not supported by
Google and Google specifically disclaims all warranties as to its quality,
merchantability, or fitness for a particular purpose.
