# LayerLens

Generate a dependency diagram in every folder of your source code.

```mermaid
flowchart TD;
generator.dart-->model.dart;
analyzer.dart-->layering.dart;
analyzer.dart-->model.dart;
analyzer.dart-->primitives.dart;
code_parser.dart-->model.dart;
code_parser.dart-->surveyor;
layering.dart-->model.dart;
model.dart-->primitives.dart;
```

## Disclaimer

This project is not an official Google project. It is not supported by
Google and Google specifically disclaims all warranties as to its quality,
merchantability, or fitness for a particular purpose.

## Prerequisites

Install `Markdown Preview Mermaid Support` extension to VSCode,
to see the diagrams in VSCode preview.

## Generate Diagrams

Run:

```
dart run layerlens
```

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for details.

## License

Apache 2.0; see [`LICENSE`](LICENSE) for details.

