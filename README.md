# LayerLens

[![pub package](https://img.shields.io/pub/v/layerlens.svg)](https://pub.dev/packages/layerlens)

Generates a dependency diagram in every folder of your Dart or Flutter
package as [Mermaid `flowchart`](https://mermaid.js.org/syntax/flowchart.html) documents.

Alerts on cyclic dependencies.

NOTE: LayerLens shows inside-package dependencies. For cross-package dependencies use `flutter pub deps`.

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

2. Find the generated file DEPENDENCIES.md in each source folder, where
   libraries or folders depend on each other.

3. In VSCode, right click DEPENDENCIES.md and select 'Open Preview'

## Continuous integration

### Fail if issues

Make your pre-submit bots failing in case of issues, using flags:

* `--fail-on-cycles`: fail if there are dependency cycles
* `--fail-if-changed`: fail if the generated diagrams has changed

### Re-generate on every GitHub push

Copy the content of [run-layerlens.yaml](https://github.com/polina-c/layerlens/blob/main/.github/doc/run-layerlens.yaml)
   to `.github/workflows`.

It will work if your repo policy allows bots to update files.

## Build filters

If you want to generate the `DEPENDENCIES.md` only for a specific folders, you can use `--build-filter` option and you should use [glob](https://pub.dev/packages/glob) syntax. For example, to generate the diagram only for the root `lib/` folder, you run following `dart run layerlens --build-filter "lib"`.

You can specify multiple build filters . The mechanism is inspired by `--build-filter` in Dart's [`build_runner`](https://github.com/dart-lang/build/blob/master/docs/partial_builds.md). For example, to run the layerlens for root `lib/` and it's subfolder `lib/subfolder1` run `layerlens --build-filter "lib" --build-filter "lib/subfolder1"`. To generate the entire subtree for a given subfolder you can run following: `layerlens --build-filter "lib/subfolder1" --build-filter "lib/subfolder1/**"`

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
