Usage of a Javascript ExpressionTool to read the contents of a file and generate some args that can be used in a downstream process.

This demo takes a list of "sample" records as input, each with a `sample_type` and `sample_id`. Then, the list of all `sample_id`'s is written to a file in a random order, simulating some command line tool that processes your sample data and embeds the sample ID's but not necessarily in the order you originally supplied them in (due to parallel processing, etc..).

A JS ExpressionTool will be used to read the contents of the file containing the `sample_id`'s and then compare the order of sample ID's to the supplied mapping of each `sample_id` to its `sample_type` in order to select just the samples that are of type "clinical". The positional index value for only the "clinical" samples is returned as a string; this would be used in downstream CommandLineTool's in order to build argument lists for use with external programs that need to operate on the files.

# Example Usage

```
$ ./run-cwltool.sh workflow.cwl input.json

...

INFO [workflow ] start
DEBUG [workflow ] inputs {
    "samples": [
        {
            "sample_id": "Sample1",
            "sample_type": "research"
        },
        {
            "sample_id": "Sample2",
            "sample_type": "research"
        },
        {
            "sample_id": "Sample3",
            "sample_type": "clinical"
        },
        {
            "sample_id": "Sample4",
            "sample_type": "research"
        },
        {
            "sample_id": "Sample5",
            "sample_type": "clinical"
        },
        {
            "sample_id": "Sample6",
            "sample_type": "research"
        }
    ]
}

...


INFO [step match_sample_types] start
WARNING Running with support for javascript console in expressions (DO NOT USE IN PRODUCTION)
INFO Javascript console output:
INFO ----------------------------------------
INFO [log] [ 'Sample4',
[log]   'Sample1',
[log]   'Sample3',
[log]   'Sample5',
[log]   'Sample6',
[log]   'Sample2',
[log]   '' ]
[log] [ 'Sample4', 'Sample1', 'Sample3', 'Sample5', 'Sample6', 'Sample2' ]
[log] [ '2', '3' ]
[log] [ { sample_id: 'Sample1', sample_type: 'research' },
[log]   { sample_id: 'Sample2', sample_type: 'research' },
[log]   { sample_id: 'Sample3', sample_type: 'clinical' },
[log]   { sample_id: 'Sample4', sample_type: 'research' },
[log]   { sample_id: 'Sample5', sample_type: 'clinical' },
[log]   { sample_id: 'Sample6', sample_type: 'research' } ]
INFO ----------------------------------------


...


INFO [workflow ] completed success
DEBUG [workflow ] outputs {
    "index_str": "2 3"
}
INFO Final process status is success
```
