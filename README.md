# LayerLens

[![pub package](https://img.shields.io/pub/v/layerlens.svg)](https://pub.dev/packages/layerlens)

Generate dependency diagram in every folder of your Dart or Flutter
package as [Mermaid `flowchart`](https://mermaid.js.org/syntax/flowchart.html) documents.

<img width="536" alt="Screenshot 2023-01-14 at 9 45 33 PM" src="https://user-images.githubusercontent.com/12115586/212524921-5221785f-692d-4464-a230-0f620434e2c5.png">


NOTE:  LayerLens shows inside-package dependencies. For cross-package dependencies use `flutter pub deps`.

## Configure layerlens

### Configure command globally

1. Run `dart pub global activate layerlens`

2. Verify you can run `layerlens`. If you get `command not found`, make sure
your path [contains pub cache](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path).

### Configure command for a package

1. Add `layerlens: <version>` to the section `dev_dependencies` in the package's pubspec.yaml.

2. Run `dart pub get` or `flutter pub get` for the package.

### Configure IDE

To see the diagrams in your IDE:

- **VSCode**: install `Markdown Preview Mermaid Support` extension

- **Android Studio**: enable the "Mermaid" extension in the
[Markdown language settings](https://www.jetbrains.com/help/idea/markdown-reference.html)

## Generate diagrams

1. Run command:

  - With global configuration: `layerlens --path <your package root>`

  - With package configuration: `dart run layerlens` in the package root

2. Find the generated file DEPENDENCIES.md in each source folder, where
libraries or folders depend on each other.

3. In VSCode, right click DEPENDENCIES.md and select 'Open Preview'

## CI: re-generate on every GitHub push

1. Add a `dev_dependency` to https://pub.dev/packages/layerlens
2. Copy the content of [run-layerlens.yaml](https://github.com/polina-c/layerlens/blob/main/.github/workflows/run-layerlens.yaml)
to `.github/workflows`.

## Alert on circular references

You may want to avoid circular references, because without circles:
1. Code is easier to maintain
2. Chance of memory leaks is smaller
3. Treeshaking (i.e. not including non-used code into build) is more efficient
4. Incremental build is faster

LayerLens marks inverted dependencies (dependencies that create circles) with '!'.

Also you can add command `dart run layerlens --fail-on-cycles` to the repo's pre-submit bots.

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
