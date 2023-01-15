# LayerLens

Generate a dependency diagram in every folder of your source code.

<img width="536" alt="Screenshot 2023-01-14 at 9 45 33 PM" src="https://user-images.githubusercontent.com/12115586/212524921-5221785f-692d-4464-a230-0f620434e2c5.png">

## Disclaimer

This project is not an official Google project. It is not supported by
Google and Google specifically disclaims all warranties as to its quality,
merchantability, or fitness for a particular purpose.

## Prerequisites

Install `Markdown Preview Mermaid Support` extension to VSCode,
to see the diagrams in preview.

## Generate diagrams for your project

1. Add dependency to https://pub.dev/packages/layerlens
2. Run `dart run layerlens` in the root of your project
3. Find the file DEPENDENCIES.md in each source folder
4. In VSCode right click the file and select 'Open Preview'

## Regenerate on every GitHub push

To make GitHub auto-generating the diagrams after every push,
copy [regenerate-dependencies.yaml](.github/workflows/regenerate-dependencies.yaml)
to `.github/workflows`.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details.

## License

Apache 2.0; see [`LICENSE`](LICENSE) for details.

