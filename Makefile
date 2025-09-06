USER=$(shell whoami)

##
## Configure the Hadoop classpath for the GCP dataproc enviornment
##

HADOOP_CLASSPATH=$(shell hadoop classpath)

WordCount1.jar: WordCount1.java
	javac -classpath $(HADOOP_CLASSPATH) -d ./ WordCount1.java
	jar cf WordCount1.jar WordCount1*.class	
	-rm -f WordCount1*.class

prepare:
	-hdfs dfs -mkdir input
	curl https://en.wikipedia.org/wiki/Apache_Hadoop > /tmp/input.txt
	hdfs dfs -put /tmp/input.txt input/file01
	curl https://en.wikipedia.org/wiki/MapReduce > /tmp/input.txt
	hdfs dfs -put /tmp/input.txt input/file02

filesystem:
	-hdfs dfs -mkdir /user
	-hdfs dfs -mkdir /user/$(USER)

run: WordCount1.jar
	-rm -rf output
	hadoop jar WordCount1.jar WordCount1 input output


##
## You may need to change the path for this depending
## on your Hadoop / java setup
##
HADOOP_V=3.3.4
STREAM_JAR = /usr/local/hadoop-$(HADOOP_V)/share/hadoop/tools/lib/hadoop-streaming-$(HADOOP_V).jar

stream:
	-rm -rf stream-output
	hadoop jar $(STREAM_JAR) \
	-mapper UrlMapper.py \
	-reducer UrlReducer.py \
	-file UrlMapper.py -file UrlReducer.py \
	-input input -output stream-output
## Hadoop Streaming on Dataproc
prepare-dataproc:
	-hdfs dfs -mkdir -p /user/$(USER)/input
	curl -sS https://en.wikipedia.org/wiki/Apache_Hadoop > /tmp/input1.txt
	hdfs dfs -put -f /tmp/input1.txt /user/$(USER)/input/file01
	curl -sS https://en.wikipedia.org/wiki/MapReduce > /tmp/input2.txt
	hdfs dfs -put -f /tmp/input2.txt /user/$(USER)/input/file02
	@echo "HDFS input prepared under /user/$(USER)/input"

stream-dataproc:
	-hdfs dfs -rm -r -f /user/$(USER)/output
	mapred streaming \
	  -D mapreduce.job.name="UrlCount-Streaming" \
	  -input /user/$(USER)/input \
	  -output /user/$(USER)/output \
	  -mapper "python3 UrlMapper.py" \
	  -reducer "python3 UrlReducer.py" \
	  -file UrlMapper.py \
	  -file UrlReducer.py
	@echo "Results are in HDFS: /user/$(USER)/output"

clean-hdfs:
	-hdfs dfs -rm -r -f /user/$(USER)/input /user/$(USER)/output
