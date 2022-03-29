#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  - class: InlineJavascriptRequirement

inputs:
  samples:
    type:
      type: array
      items:
        type: record
        fields:
          sample_id: string
          sample_type: string

outputs:
  index_str:
    type: string
    outputSource: match_sample_types/index_str

steps:
  # get a list of just the sample IDs for downstream use
  get_sample_ids:
    in:
      samples: samples
    out: [ sample_ids ]
    run:
      class: ExpressionTool
      inputs:
        samples:
          type:
            type: array
            items:
              type: record
              fields:
                sample_id: string
                sample_type: string
      outputs:
        sample_ids: string[]
      expression: |
        ${
          var sample_ids = [];
          for ( var i in inputs.samples ){
            sample_ids.push(inputs.samples[i]['sample_id']);
          };
          console.log(sample_ids);
          return {'sample_ids': sample_ids};
        }

  # write the sample IDs to file in a random order
  write_sample_ids:
    in:
      sample_ids: get_sample_ids/sample_ids
    out: [ shuff_txt ]
    run:
      class: CommandLineTool
      baseCommand: ['bash', 'run.sh']
      inputs:
        sample_ids: string[]
      outputs:
        shuff_txt:
          type: File
          outputBinding:
            glob: shuf.txt
      requirements:
        InitialWorkDirRequirement:
          listing:
            - entryname: run.sh
              entry: |-
                set -euo pipefail
                touch file.txt
                for i in ${return inputs.sample_ids.join(' '); }; do echo "\${i}" >> file.txt; done
                cat file.txt | shuf > shuf.txt

  # read the shuffled file and identify the order of research and clinical samples
  match_sample_types:
    in:
      samples: samples
      shuff_txt: write_sample_ids/shuff_txt
    out: [ index_str ]
    run:
      class: ExpressionTool
      inputs:
        samples:
          type:
            type: array
            items:
              type: record
              fields:
                sample_id: string
                sample_type: string
        shuff_txt:
          type: File
          inputBinding:
            loadContents: true
      outputs:
        index_str: string
      expression: |
        ${
          var lines = inputs.shuff_txt.contents.split('\n');
          var shuffled_ids = [];
          var clinical_indexes = [];

          for ( var i in lines ){
            // watch out for empty strings
            if (lines[i]){

              // save the sample ID
              var id = lines[i];
              shuffled_ids.push(id);

              // look up the sample in the samples map to find out if its clinical
              var is_clinical = false;
              for ( var q in inputs.samples){
                if ( inputs.samples[q]['sample_id'] === id ){
                  if ( inputs.samples[q]['sample_type'] == 'clinical' ){
                    is_clinical = true ;
                  };
                };
              };

              if (is_clinical){
                clinical_indexes.push(i);
              };

            };
          };

          console.log(lines);
          console.log(shuffled_ids);
          console.log(clinical_indexes);
          console.log(inputs.samples);

          return {'index_str': clinical_indexes.join(' ')};
        }
