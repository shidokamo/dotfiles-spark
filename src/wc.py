import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode
from pyspark.sql.functions import split

server = sys.argv[1]
subscription = "subscribe"
topics = "word"

spark = SparkSession.builder.appName("wc").getOrCreate()
lines = spark.\
        readStream.\
        format("kafka").\
        option("kafka.bootstrap.servers", server).\
        option(subscription, topics).\
        load().\
        selectExpr("CAST(value AS STRING)")

words = lines.\
        select(
            explode(
                split(lines.value, ' ')
            ).alias('word')
        )
wordCounts = words.groupBy('word').count()
query = wordCounts.writeStream.outputMode('complete').format('console').start()
query.awaitTermination()
