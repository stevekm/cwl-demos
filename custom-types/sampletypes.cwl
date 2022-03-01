#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  - $import: sampletypes.yml
 # - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
 # - class: StepInputExpressionRequirement


inputs:
  sample: "sampletypes.yml#Sample"
    # type:
    #   type: record
    #   fields:
    #     sample_id: string
    #     normal_id: string

  # samples:
  #   type:
  #     type: array
  #     items:
  #       type: record
  #       fields:
  #         sample_id: string
  #         normal_id: string

outputs: []
  # sample:
  #   type: "sampletypes.yml#Sample"
  #   outputSource: collect_output/sample

steps:
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
        console.log('foo');
        return { 'sample': inputs.sample };
        }

  process_sample:
    in:
      sample: collect_output/sample
    out: [ sample_file, sample, new_sample ]
    run:
      class: CommandLineTool
      baseCommand: ['touch', 'output.txt']
      inputs:
        sample: "sampletypes.yml#Sample"
      outputs:
        sample_file:
          type: File
          outputBinding:
            glob: output.txt
        sample:
          type: "sampletypes.yml#Sample"
          outputBinding:
            outputEval: $(inputs.sample)
        new_sample:
          type: "sampletypes.yml#Sample"
          outputBinding:
            outputEval: ${
              console.log("process_sample fooo");
              var ret = inputs.sample;
              ret['sample_file'].path = runtime.outdir + "/" + "output.txt";
              return ret;
              }
