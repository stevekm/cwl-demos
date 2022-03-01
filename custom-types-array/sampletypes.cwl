#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  - $import: sampletypes.yml
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement


inputs:
  samples: sampletypes.yml#Sample[]

outputs:
  old_samples:
    type: "sampletypes.yml#Sample[]"
    outputSource: sample_workflow/old_sample
  new_samples:
    type: "sampletypes.yml#Sample[]"
    outputSource: sample_workflow/new_sample

steps:
  sample_workflow:
    scatter: sample
    in:
      sample: samples
    out: [ new_sample, old_sample ]
    run:
      class: Workflow
      inputs:
        sample: "sampletypes.yml#Sample"
      outputs:
        new_sample:
          type: "sampletypes.yml#Sample"
          outputSource: process_sample/new_sample
        old_sample:
          type: "sampletypes.yml#Sample"
          outputSource: process_sample/old_sample
      steps:
        # an ExpressionTool that takes a custom type object in and returns one in outputs
        collect_output:
          in:
            sample: sample
          out: [ sample ]
          run:
            class: ExpressionTool
            inputs:
              sample: "sampletypes.yml#Sample"
            outputs:
              sample: "sampletypes.yml#Sample"
            expression: |
              ${
              return { 'sample': inputs.sample };
              }

        # a CommandLineTool that takes a custom type obj in,
        # and outputs a new custom type object with a new file but retaining some of the original fields
        process_sample:
          in:
            sample: collect_output/sample
          out: [ sample_file, old_sample, new_sample ]
          run:
            class: CommandLineTool
            baseCommand: ['touch', 'output.txt']
            inputs:
              sample: "sampletypes.yml#Sample"
            outputs:
              # just the new file output
              sample_file:
                type: File
                outputBinding:
                  glob: output.txt
              # the original custom object returned back out
              old_sample:
                type: "sampletypes.yml#Sample"
                outputBinding:
                  outputEval: $(inputs.sample)
              # modify the original object to include the new file output
              new_sample:
                type: "sampletypes.yml#Sample"
                outputBinding:
                  outputEval: ${
                    var ret = inputs.sample;
                    ret['sample_file'] = {"class":"File", "path":runtime.outdir + "/" + "output.txt"};
                    return ret;
                    }
