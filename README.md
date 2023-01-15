# LayerLens

Generate dependency diagram in every folder of your source code.

<img width="536" alt="Screenshot 2023-01-14 at 9 45 33 PM" src="https://user-images.githubusercontent.com/12115586/212524921-5221785f-692d-4464-a230-0f620434e2c5.png">

[Layerlens on pub.dev](https://pub.dev/packages/layerlens)

## Disclaimer

This project is not an official Google project. It is not supported by
Google and Google specifically disclaims all warranties as to its quality,
merchantability, or fitness for a particular purpose.

## Prerequisites

Install `Markdown Preview Mermaid Support` extension to VSCode,
to see the diagrams locally, in preview.

## Generate diagrams for your project

1. Add dependency to https://pub.dev/packages/layerlens
2. Run `dart run layerlens` in the root of your project
3. Find the generated file DEPENDENCIES.md in a source folder
4. In VSCode, right click the file and select 'Open Preview'

## CI: re-generate on every GitHub push

To make GitHub re-generating the diagrams after every push,
copy [regenerate-dependencies.yaml](.github/workflows/regenerate-dependencies.yaml)
to `.github/workflows`.

## Alert on circular references

If you want presubmit alerting for circular references, upvote [the issue](https://github.com/polina-c/layerlens/issues/4) and explain why you want it.

## Supported languages

While lauerlens diagramming is language agnistic, for now only `dart` is supported.
Please [submit an issue](https://github.com/polina-c/layerlens/issues/new) if you want other language to be added.

## Contribute to layerlens

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details.

## License

Apache 2.0; see [`LICENSE`](LICENSE) for details.
