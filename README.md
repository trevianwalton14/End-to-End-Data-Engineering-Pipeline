# End-to-End-Data-Engineering-Pipeline
End to End Data Engineering Overview </br>
This project demonstrates an end-to-end serverless data engineering pipeline on AWS. It ingests raw CSV/JSON data into Amazon S3 and performs schema discovery and ETL using AWS Glue. 

<a href = "https://lucid.app/lucidchart/59fed51c-4985-4cd5-9b91-92494e4a1604/view">Architecture Design</a>

Step by Step Overview
Step 1: S3 Buckets
-	In this project three buckets will be created. A source bucket will be used to store the raw input data. The data can be in various formats such as CSV, JSON , etc. A destination bucket where the processed or transformed data is written by the AWS Glue Job. After AWS Glue performs the necessary transformation on the source data, the output is saved here. The Code Bucket contains the script files used by the AWS Glue job. 
-	 <img width="2150" height="1066" alt="EndtoEnd-S3 Buckets" src="https://github.com/user-attachments/assets/915c17db-e801-4414-82af-ee4545b2f5f3" />

Step 2: IAM Glue Role and Policy
-	In this project I will create an IAM Role for AWS Glue to have permission to access the s3 buckets. The IAM Policy will specify which permissions AWS Glue wil have to access AWS resources. 
-	 <img width="975" height="495" alt="image" src="https://github.com/user-attachments/assets/112133f9-8d73-41cf-95b7-68a78ba8d707" />
-	 <img width="975" height="740" alt="image" src="https://github.com/user-attachments/assets/e15c91ea-8304-431e-a26a-8634aa199e78" />
Step 3: AWS Glue Catalog and Crawler
-	In this project I created an AWS Crawler to inspect the data to determine its structure, its data type and any potential partitions.
-	<img width="2680" height="1166" alt="EndToEnd-AWSCrawler" src="https://github.com/user-attachments/assets/0bb240d4-8f02-44be-a6c8-22b89c6abeb2" />

-	The Glue Catalog contains the table that represents data in underlying storage systems, and it provides information such as table schemas, data locations and data formats. 
-	 <img width="2744" height="212" alt="EndToEnd-AWSCrawlerCatalog" src="https://github.com/user-attachments/assets/cdf0f147-b24e-4723-b434-df402833d893" />

-	The Crawler triggers will start the Crawler automatically and will pass the table to the Glue Catalog. 
-	 <img width="2728" height="287" alt="EndToEnd-AWSCrawler-Trigger" src="https://github.com/user-attachments/assets/4afc5c20-daf5-42fa-887e-69c91ee097f1" />

Step 4: PySpark Script
-	I created a pyspark script will perform the ETL process.
-	 <img width="2270" height="1454" alt="EndToEnd-Python Script" src="https://github.com/user-attachments/assets/47eb3bd6-d53a-48d7-a6c1-80947828ec35" />

Step 5: AWS Glue Job
-	I created an AWS job that uses a PySpark script to transform data and writes the optimized data to a processed s3 bucket. 
-	 <img width="2248" height="782" alt="EndToEnd-AWSGlueJob" src="https://github.com/user-attachments/assets/ee0ecf77-992f-4a6b-944f-20ddccb618d8" />

