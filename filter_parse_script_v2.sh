#!/bin/bash
# Input SAM file
input_sam=$1
# Output CSV file
output_csv="${input_sam%.txt}.csv"
# Write the CSV header
echo "SRR,contig_id,ARO_ID,Alignment_Length,Identity" > "$output_csv"
# Process the SAM file
awk 'BEGIN {OFS=","}
     !/^@/ {
         # Extract SRR number (use simpler regex)
         split($1, srr_parts, "_");
         srr_number = srr_parts[1];
         
         # Extract contig ID (new)
         split($1, contig_parts, "_");
         contig_id = contig_parts[1] "_" contig_parts[2];
 
         # Extract ARO ID
         match($3, /ARO:[0-9]+/);
         aro_id = substr($3, RSTART, RLENGTH);
         # Extract CIGAR string and calculate alignment length
         cigar = $6;
         match_len = 0;
         while (match(cigar, /[0-9]+[MIDNSHP=X]/)) {
             len = substr(cigar, RSTART, RLENGTH);
             type = substr(len, length(len), 1);
             if (type == "M") {
                 match_len += int(substr(len, 1, length(len) - 1));
             }
             cigar = substr(cigar, RSTART + RLENGTH);
         }
         # Extract NM tag (number of mismatches)
         nm_tag = 0;
         for (i = 12; i <= NF; i++) {
             if ($i ~ /^NM:i:/) {
                 nm_tag = substr($i, 6);
                 break;
             }
         }
         # Calculate identity
         if (match_len > 0) {
             identity = (1 - nm_tag / match_len) * 100;
         } else {
             identity = 0;
         }
         # Apply filters: match_len > 100 and reference name starts with "card_nucl.gb"
         if (match_len > 100 && $3 ~ /^card_nucl\.gb/ && identity >= 80) {
             # Print the extracted data as CSV
             print srr_number, contig_id, aro_id, match_len, identity;
         }
     }' "$input_sam" >> "$output_csv"
echo "Processing complete. Results saved to $output_csv."

