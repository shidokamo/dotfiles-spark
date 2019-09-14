import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import explode
from pyspark.sql.functions import split

server = sys.argv[1]
subscription = "subscribe"
in_topics = "word"
out_topics = "wc"

spark = SparkSession.builder.appName("wc").getOrCreate()
lines = spark.\
        readStream.\
        format("kafka").\
        option("kafka.bootstrap.servers", server).\
        option(subscription, in_topics).\
        load().\
        selectExpr("CAST(value AS STRING)")

words = lines.\
        select(
            explode(
                split(lines.value, ' ')
            ).alias('word')
        )
wordCounts = words.groupBy('word').count()
# Write data to a specific Kafka topic specified in an option
# Checkpoint must be specified.
query = wordCounts\
          .selectExpr("to_json(struct(*)) AS value")\
          .writeStream\
          .outputMode('complete')\
          .format('kafka')\
          .option("kafka.bootstrap.servers", server)\
          .option("topic", out_topics)\
          .option("checkpointLocation", "/opt/spark/state")\
          .start()

query.awaitTermination()
