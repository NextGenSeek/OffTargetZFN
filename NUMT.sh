for f1 in *_1.fq.gz
do
        echo -n "Quality trimming and trimming adapters... $f1 "
        f2=${f1%%_1.fq.gz}"_2.fq.gz"
                trim_galore --paired $f1 $f2 --dont_gzip --output_dir ./assembly

        echo " Done"
done

for f1 in *_1_val_1.fq       
do
        echo -n "mapping to genome $f1"
        f2=${f1%%_1_val_1.fq}"_2_val_2.fq"                      
        bowtie2 --very-sensitive -p 4 --np 0 --rdg 0 --rfg 0 --no-mixed --no-unal -x /PATH/TO/NUMT_Genome_File -1 $f1 -2 $f2 | samtools view -@ 5 -bS -o $f1.bam
        echo " Done"
done

for f1 in *.bam
do
		echo -n "sort bam files $f1"
        samtools sort -@ 5 $f1 -o $f1.sorted.bam 
        echo " Done"
done

for f1 in *.sorted.bam
do
        echo -n "index $f1"
        samtools index -@ 5 $f1
        echo " Done"
done

for f3 in *sorted.bam
do
	echo -n “extract NUMT”
	samtools view $f3 NUMT:StartRegion-EndRegion -o $f3_NUMT.bam
echo “Done”
done

for f2 in *NUMT.bam.sorted.bam
do
		echo -n “stats $f2”
		samtools flagstat $f2 > report_$f2.txt
 		echo "Done"
done

for f2 in *NUMT.bam.sorted.bam
do
	echo -n “deletion $f2”
	samtools view $f2 | cut -f 6 | grep -c 'D' > deletions_$f2.txt
done

for f2 in *NUMT.bam.sorted.bam
do
        echo -n “deletion $f2”
        samtools view $f2 | cut -f 6 | grep -c 'I' > insertions_$f2.txt
done
