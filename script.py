import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions  
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Get job arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Initialize Spark and Glue contexts, and Sparksession
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

#Create Glue job
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

AWSGlueDataCatalog_node1 = glueContext.create_dynamic_frame.from_catalog(
    database = "endtoend_glue_database", 
    table_name = "endtoend-source-bucket-1234567", 
    transformation_ctx = "AWSGlueDataCatalog_node1"
    )

ChangeSchema_node2 = ApplyMapping.apply(
    frame = AWSGlueDataCatalog_node1,
    mappings = [
        ("id", "long", "id", "long"), 
        ("organization id", "string", "organization id", "string"),
        ("name", "string", "name", "string"), 
        ("website", "string", "website", "string"), 
        ("country", "string", "country", "string")
        ("email", "string", "email", "string")
    ],
    trandormation_ctx = "ChangeSchema_node2")

AmazonS3_node3 = glueContext.write_dynamic_frame.from_options(
    frame = ChangeSchema_node2,
    connection_type = "s3",
    format = "csv",
    connection_options = {"path": "s3://endtoend-destination-bucket-1234567/"},
    transformation_ctx = "AmazonS3_node3"
)
job.commit()