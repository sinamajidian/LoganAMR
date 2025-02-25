# Logan AMR


Here we describe how we analyse the AMR gene in the Logan database for human metagenomics samples. 


## CARD alignment

We used the alignment that Rayan prepared using minimap2 with card nucleotides as the reference and Logan contigs as query [here](https://gitlab.pasteur.fr/rchikhi_pasteur/logan-analysis/-/blob/master/batch/tasks/analysis_aug26.sh?ref_type=heads#L113). We downloaded them in bash after installing cli with ` conda install conda-forge::awscli`:

```
for i in {0..5}; do
aws s3 cp s3://serratus-rayan/beetles/logan_aug26_run/minimap2-concat/DRR${i}.all_minimap2.txt.zst  . --no-sign-request 
done
for i in {0..19}; do
aws s3 cp s3://serratus-rayan/beetles/logan_aug26_run/minimap2-concat/ERR${i}.all_minimap2.txt.zst  . --no-sign-request  & 
done

for i in {0..29}; do
aws s3 cp s3://serratus-rayan/beetles/logan_aug26_run/minimap2-concat/SRR${i}.all_minimap2.txt.zst  . --no-sign-request  & 
done
```

The following is the full list provided by Rayan. Note that these include alignment on CARD genes and some other genes too.  

```
s3://serratus-rayan/beetles/logan_aug26_run/minimap2-concat/

2024-08-28 10:15:21  371052558 DRR0.all_minimap2.txt.zst
2024-08-28 10:15:21  647910626 DRR1.all_minimap2.txt.zst
2024-08-28 10:15:21  457751590 DRR2.all_minimap2.txt.zst
2024-08-28 10:15:22  857890075 DRR3.all_minimap2.txt.zst
2024-08-28 10:15:22  202246715 DRR4.all_minimap2.txt.zst
2024-08-28 10:16:00   89378678 DRR5.all_minimap2.txt.zst
2024-08-28 10:16:15         13 DRR6.all_minimap2.txt.zst
2024-08-28 10:16:15         13 DRR7.all_minimap2.txt.zst
2024-08-28 10:16:15         13 DRR8.all_minimap2.txt.zst
2024-08-28 10:16:16         13 DRR9.all_minimap2.txt.zst
2024-08-28 10:16:16  431991729 ERR0.all_minimap2.txt.zst
2024-08-28 10:16:17 6336161821 ERR10.all_minimap2.txt.zst
2024-08-28 10:16:32 6204306329 ERR11.all_minimap2.txt.zst
2024-08-28 10:16:56 3669458241 ERR12.all_minimap2.txt.zst
2024-08-28 10:17:16  598494151 ERR13.all_minimap2.txt.zst
2024-08-28 10:17:24  548135065 ERR14.all_minimap2.txt.zst
2024-08-28 10:18:51  933368129 ERR15.all_minimap2.txt.zst
2024-08-28 10:18:51 1076364600 ERR16.all_minimap2.txt.zst
2024-08-28 10:21:12 1120320884 ERR17.all_minimap2.txt.zst
2024-08-28 10:21:31  874663559 ERR18.all_minimap2.txt.zst
2024-08-28 10:23:35  750815270 ERR19.all_minimap2.txt.zst
2024-08-28 10:23:51 6268457637 ERR2.all_minimap2.txt.zst
2024-08-28 10:25:18 9993517040 ERR3.all_minimap2.txt.zst
2024-08-28 10:25:35 9267182339 ERR4.all_minimap2.txt.zst
2024-08-28 10:31:07 3915070471 ERR5.all_minimap2.txt.zst
2024-08-28 10:31:08 2541042752 ERR6.all_minimap2.txt.zst
2024-08-28 10:37:12 3325229673 ERR7.all_minimap2.txt.zst
2024-08-28 10:38:32 2771554719 ERR8.all_minimap2.txt.zst
2024-08-28 10:40:33 3626169113 ERR9.all_minimap2.txt.zst
2024-08-28 10:44:59  146069636 SRR0.all_minimap2.txt.zst
2024-08-28 10:45:01 11348022730 SRR10.all_minimap2.txt.zst
2024-08-28 10:45:21 8407908434 SRR11.all_minimap2.txt.zst
2024-08-28 10:47:21 10661405695 SRR12.all_minimap2.txt.zst
2024-08-28 10:48:41 9492194646 SRR13.all_minimap2.txt.zst
2024-08-28 10:48:50 7413405737 SRR14.all_minimap2.txt.zst
2024-08-28 11:03:57 7648322059 SRR15.all_minimap2.txt.zst
2024-08-28 11:05:14 5723214084 SRR16.all_minimap2.txt.zst
2024-08-28 11:09:37 6749309333 SRR17.all_minimap2.txt.zst
2024-08-28 11:10:09 6397643385 SRR18.all_minimap2.txt.zst
2024-08-28 11:11:10 6326232994 SRR19.all_minimap2.txt.zst
2024-08-28 11:18:48 3757069872 SRR20.all_minimap2.txt.zst
2024-08-28 11:21:57 8394866429 SRR21.all_minimap2.txt.zst
2024-08-28 11:25:45 6557221790 SRR22.all_minimap2.txt.zst
2024-08-28 11:25:56 5728639528 SRR23.all_minimap2.txt.zst
2024-08-28 11:26:15 6339826040 SRR24.all_minimap2.txt.zst
2024-08-28 11:27:30 6444525433 SRR25.all_minimap2.txt.zst
2024-08-28 11:38:41 5748408269 SRR26.all_minimap2.txt.zst
2024-08-28 11:40:21  762723522 SRR27.all_minimap2.txt.zst
2024-08-28 11:40:24   72371823 SRR28.all_minimap2.txt.zst
2024-08-28 11:40:36  473396708 SRR29.all_minimap2.txt.zst
2024-08-28 11:40:57 3782849163 SRR3.all_minimap2.txt.zst
2024-08-28 11:41:36 1950625395 SRR4.all_minimap2.txt.zst
2024-08-28 11:41:53 8160696003 SRR5.all_minimap2.txt.zst
2024-08-28 11:42:01 8444681997 SRR6.all_minimap2.txt.zst
2024-08-28 11:45:55 10861570542 SRR7.all_minimap2.txt.zst
2024-08-28 11:49:19 10454135424 SRR8.all_minimap2.txt.zst
2024-08-28 11:51:18 7097929783 SRR9.all_minimap2.txt.zst

example:
 aws s3 cp  s3://serratus-rayan/beetles/logan_aug26_run/minimap2-concat/SRR29.all_minimap2.txt.zst . --no-sign-request
```
We uncompressed them  with zstd (`conda install conda-forge::zstd`).
```
for i in {0..5}; do
zstd -d DRR${i}.all_minimap2.txt.zst  
done

for i in {0..19}; do
zstd -d ERR${i}.all_minimap2.txt.zst  
done

for i in {0..29}; do
zstd -d SRR${i}.all_minimap2.txt.zst  
done
```
Note that three files are empty (ERR1 SRR1 SRR2).

## filtering SAM

Then we filter sam alignments using `filter_parse_script_v2.sh` provided in this repo for keeping only card alignments and removing short alignments. 

and combine the result as `all_alignments.csv` 26GB.



## finding accessions


We used the SRA metadata that Kristen provided `SRA_metadata.csv` (9.6GB) with 32,755,969 SRA accessions. we extracted accessions of human gut microbiom (in python). We also filtered to those accessions that have collection date in range 2009-2024 (for some accessions there is only release date not collection date.) We selected accessions in 6 continents. This resulted in 296764 acessions. 

```
file_ad=folder+"SRA_metadata.csv"
meta = pd.read_csv(file_ad)
meta2 = meta[meta['organism']=="human gut metagenome"]
meta3 = meta2[meta2['collection_date_sam'].notna()]
meta3["collection_year"]=meta3.collection_date_sam.apply(lambda x: int(str(x)[1:5]))
meta3_ = meta3[meta3['geo_loc_name_country_continent_calc'].isin(['Africa','Asia','Europe','North America','Oceania','South America'])] 
meta4 = meta3_[meta3_['collection_year'].isin(list(range(2009,2024)))] 
acc_humangut_wrelease_continent= set(meta4['acc'])
print(len(acc_humangut_wrelease_continent)) 
```


Then we filter the alignment to these accessions in python with 
```
folder="aligmnet_minimap/"
file_ad=folder+"all_alignments.csv"
file=open(file_ad,'r')

file_out=open(file_ad+"_humangut_wcollection_continent_.csv",'w')

for line in file:
    line_strip= line.strip()
    idd=line_strip.split(",")[0]
    if idd in acc_humangut_wrelease_continent:
       file_out.write(line_strip+"\n")         
file_out.close()

```
