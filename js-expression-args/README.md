Usage of a Javascript ExpressionTool to create a command line argument to use in a downstream CommandLineTool

This workflow (`js-args.cwl`) will simulate the processing of an unknown number of samples in a bash command line that requires writing a shell command dynamically based on the input values.

The input for this workflow is a list of sample identifiers. The workflow task `make_args` will use an embedded Javascript expression to create a `grep -v ... | ` command in order to filter out all input sample ID's from the output file in workflow step `use_args`.

Multiple input files are included:

- input_0.json : 0 input sample ID's

- input_1.json : 1 input sample ID

- input_2.json : 2 input sample ID's

The `make_args` JS expression is designed to produce a functional bash command snippet for 0, 1, or >1 input arguments.

# Example Usage

0 samples:

```
$ ./run-cwltool.sh js-args.cwl input_0.json
...
{
    "output_file": {
        "location": ".../output.txt",
        "basename": "output.txt",
        "class": "File",
        "checksum": "sha1$7b79fd2650d3cd8714b6b673ae57cad18dd7c8dc",
        "size": 18,
        "path": "output.txt"
    },
...
}

$ cat output.txt
samples_arg:
foo
```

1 sample:

```
$ ./run-cwltool.sh js-args.cwl input_1.json
...
{
    "output_file": {
        "location": ".../output.txt",
        "basename": "output.txt",
        "class": "File",
        "checksum": "sha1$4f30467f145f82101dbae03d9782cbd1e5b219bf",
        "size": 38,
        "path": "output.txt"
    },
    ...
}

$ cat output.txt
samples_arg: | grep -v "Sample1"
foo

```

2 samples:

```
$ ./run-cwltool.sh js-args.cwl input_2.json
...
{
    "output_file": {
        "location": ".../output.txt",
        "basename": "output.txt",
        "class": "File",
        "checksum": "sha1$a5b0b62ff32cd3108ef5bb36fc9f3f896a13dd14",
        "size": 59,
        "path": "output.txt"
    },
    ...
}

$ cat output.txt
samples_arg: | grep -v "Sample1"  | grep -v "Sample2"
foo
```
