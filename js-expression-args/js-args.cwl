#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  - class: InlineJavascriptRequirement

inputs:
  samples: string[]

outputs:
  output_file:
    type: File
    outputSource: use_args/output_file
  run_script:
    type: File
    outputSource: use_args/run_script
  stdout_txt:
    type: File
    outputSource: use_args/stdout_txt

steps:
  make_args:
    in:
      samples: samples
    out: [ samples_arg ]
    run:
      class: ExpressionTool
      doc: creates the expression '| grep -v  "Sample1"  | grep -v  "Sample2"'
      inputs:
        samples: string[]
      outputs:
        samples_arg: string
      # NOTE: this indentation is important!
      expression: |
        ${
          // this is a javascript comment
          console.log("\nthis is example console output");

          var arg = '';
          var num_args = inputs.samples.length;
          console.log("num_args");
          console.log(num_args);

          if (num_args > 0){
            // need to start the bash command with a | character if there are args
            arg = arg + '| '
          };

          // i is an int representing the index in the array
          for ( var i in inputs.samples ){
            var sample_id = inputs.samples[i];
            console.log(i);
            console.log(sample_id);

            // make sure to use ' ' here to avoid bash quote issues later
            arg = arg + 'grep -v "' + sample_id + '" ';

            // need to apply the | between all args except the final one
            if (i < num_args - 1){
              console.log("i is smaller than num_args");
              arg = arg + ' | ';
            };
          };

          console.log("arg:");
          console.log(arg);

          return {'samples_arg': arg};
        }

  use_args:
    in:
      samples_arg: make_args/samples_arg
      samples: samples
    out: [ output_file, run_script, stdout_txt ]
    run:
      class: CommandLineTool
      baseCommand: ['bash', 'run.sh']
      inputs:
        samples: string[]
        samples_arg: string
      outputs:
        output_file:
          type: File
          outputBinding:
            glob: output.txt
        run_script:
          type: File
          outputBinding:
            glob: run.sh
        stdout_txt:
          type: File
          outputBinding:
            glob: stdout.txt
      requirements:
        InitialWorkDirRequirement:
          listing:
            - entryname: run.sh
              entry: |-
                set -euo pipefail
                set -x
                (
                # dont actually use this samples_arg in the script because the shell messes up the quoting when evaluating a variable it seems
                samples_arg='${ return inputs.samples_arg ; }'
                samples="${return inputs.samples.join(' '); }"

                # write some lines to a file
                echo foo > tmp
                for i in \${samples}; do echo \${i} >> tmp; done

                echo "samples_arg: \${samples_arg}" > output.txt

                # pipe is included in the samples_arg so this can still work with no args passed
                cat tmp ${ return inputs.samples_arg ; } >> output.txt
                ) 2>&1 | tee stdout.txt
