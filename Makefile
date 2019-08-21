CPU ?= 32
BASE ?= $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

secondary: shasta minimap2 samtools marginpolish helen
	
tertiary: gatk

download:
	echo "Downloading test sample..."
	# wget -N https://lc2019.s3-us-west-2.amazonaws.com/sample_data/GM24385/GM24385.chr20.fq
	# sed -n '1~4s/^@/>/p;2~4p' GM24385.chr20.fq > GM24385.chr20.fasta
	# md5sum -c $(BASE)GM24385.chr20.fq.md5
	# echo "Verifying..."
	wget -N https://s3-us-west-2.amazonaws.com/lc2019/shasta/ecoli_test/r94_ec_rad2.181119.60x-10kb.fasta.gz;
	gunzip --force r94_ec_rad2.181119.60x-10kb.fasta.gz;
	md5sum -c $(BASE)r94_ec_rad2.181119.60x-10kb.fasta.md5
	mv r94_ec_rad2.181119.60x-10kb.fasta original.fasta

shasta:
	rm -rf ShastaRun
	docker run -it --rm --user=`id -u`:`id -g` --cpus="$(CPU)" -v `pwd`:/data \
		tpesout/shasta@sha256:048f180184cfce647a491f26822f633be5de4d033f894ce7bc01e8225e846236 \
		--input original.fasta
	mv ShastaRun/Assembly.fasta shasta.fasta

minimap2:
	docker run -it --rm --user=`id -u`:`id -g` --cpus="$(CPU)" -v `pwd`:/data \
		tpesout/minimap2@sha256:5df3218ae2afebfc06189daf7433f1ade15d7cf77d23e7351f210a098eb57858 \
		-ax map-ont -t $(CPU) shasta.fasta original.fasta

samtools:
	docker run -it --rm --user=`id -u`:`id -g` --cpus="$(CPU)" -v `pwd`:/data \
		tpesout/samtools_sort:latest \
		/data/minimap2.sam -@ $(CPU)
	docker run -it --rm --user=`id -u`:`id -g` --cpus="$(CPU)" -v `pwd`:/data \
		tpesout/samtools_view@sha256:11faa9b074b3ec96f50f62133bd19f819bd5bf6ad879d913ac45955f95dd91fb \
		-hb -F 0x104 /data/samtools_sort.bam
	docker run -it --rm --user=`id -u`:`id -g` --cpus="$(CPU)" -v `pwd`:/data \
		quay.io/ucsc_cgl/samtools:1.8--cba1ddbca3e1ab94813b58e40e56ab87a59f1997 \
		index -@ $(CPU) /data/samtools_sort.bam

marginpolish:
	docker run -it --rm --user=`id -u`:`id -g` --cpus="$(CPU)" -v `pwd`:/data \
		tpesout/margin_polish@sha256:de10c726bcc6af2f58cbb35af32ed0f0d95a3dc5f64f66dcc4eecbeb36f98b65 \
		/data/samtools_sort.bam /data/shasta.fasta \
		/opt/MarginPolish/params/allParams.np.human.guppy-ff-235.json -t $(CPU) -o /data/marginPolish/ -f

helen:
	echo "Helen not working yet..."
	# wget -N https://storage.googleapis.com/kishwar-helen/helen_trained_models/v0.0.1/r941_flip235_v001.pkl 
	# docker run -it --rm --user=`id -u`:`id -g` --cpus="$(CPU)" -v `pwd`:/data \
	# 	kishwars/helen:0.0.1.cpu \
	# 	call_consensus.py -i /data/marginPolish -m r941_flip235_v001.pkl -o helen -w $(CPU)

gatk:
	echo "Wish I was running something here..."
