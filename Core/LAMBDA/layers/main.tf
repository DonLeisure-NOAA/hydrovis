variable "environment" {
  description = "Hydrovis environment"
  type        = string
}

variable "region" {
  description = "Hydrovis environment"
  type        = string
}

variable "viz_environment" {
  description = "Visualization environment for code that should be used."
  type        = string
}

variable "deployment_bucket" {
  description = "S3 buckets where the lambda zip files will live."
  type        = string
}

######################
## ES Logging Layer ##
######################

resource "aws_s3_object" "es_logging" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/es_logging.zip"
  source = "${path.module}/es_logging.zip"
  source_hash = filemd5("${path.module}/es_logging.zip")
}

resource "aws_lambda_layer_version" "es_logging" {
  s3_bucket = aws_s3_object.es_logging.bucket
  s3_key = aws_s3_object.es_logging.key

  layer_name = "es_logging_${var.environment}"

  compatible_runtimes = ["python3.6", "python3.7", "python3.8"]
  description         = "Custom logger that formats logs for AWS elasticsearch ingest"
}

#######################################
## Viz Lambda Shared Functions Layer ##
#######################################

data "archive_file" "viz_lambda_shared_funcs_zip" {
  type = "zip"

  source_dir = "${path.module}/viz_lambda_shared_funcs"

  output_path = "${path.module}/temp/viz_lambda_shared_funcs_${var.environment}_${var.region}.zip"
}

resource "aws_s3_object" "viz_lambda_shared_funcs_zip_upload" {
  bucket      = var.deployment_bucket
  key         = "terraform_artifacts/${path.module}/viz_lambda_shared_funcs.zip"
  source      = data.archive_file.viz_lambda_shared_funcs_zip.output_path
  source_hash = filemd5(data.archive_file.viz_lambda_shared_funcs_zip.output_path)
}

resource "aws_lambda_layer_version" "viz_lambda_shared_funcs" {
  s3_bucket = aws_s3_object.viz_lambda_shared_funcs_zip_upload.bucket
  s3_key = aws_s3_object.viz_lambda_shared_funcs_zip_upload.key

  layer_name = "viz_lambda_shared_funcs_${var.environment}"

  compatible_runtimes = ["python3.7", "python3.8"]
  description         = "Viz classes and helper functions for general viz lambda functionality"
}

#############################
## ArcGIS Python API Layer ##
#############################

resource "aws_s3_object" "arcgis_python_api" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/arcgis_python_api.zip"
  source = "${path.module}/arcgis_python_api.zip"
  source_hash = filemd5("${path.module}/arcgis_python_api.zip")
}

resource "aws_lambda_layer_version" "arcgis_python_api" {
  s3_bucket = aws_s3_object.arcgis_python_api.bucket
  s3_key = aws_s3_object.arcgis_python_api.key

  layer_name = "arcgis_python_api_${var.environment}"

  compatible_runtimes = ["python3.9"]
  description         = "ArcGIS Python API module"
}

##################
## Pandas Layer ##
##################

resource "aws_s3_object" "pandas" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/pandas.zip"
  source = "${path.module}/pandas.zip"
  source_hash = filemd5("${path.module}/pandas.zip")
}

resource "aws_lambda_layer_version" "pandas" {
  s3_bucket = aws_s3_object.pandas.bucket
  s3_key = aws_s3_object.pandas.key

  layer_name = "pandas_${var.environment}"

  compatible_runtimes = ["python3.9"]
  description         = "pandas python package"
}

##################
## GeoPandas Layer ##
##################


resource "aws_s3_object" "geopandas" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/geopandas.zip"
  source = "${path.module}/geopandas.zip"
  source_hash = filemd5("${path.module}/geopandas.zip")
}

resource "aws_lambda_layer_version" "geopandas" {
  s3_bucket = aws_s3_object.geopandas.bucket
  s3_key = aws_s3_object.geopandas.key

  layer_name = "geopandas_${var.environment}"

  compatible_runtimes = ["python3.9"]
  description         = "geopandas python package"
}

##################################
## Psycopg2 & SQL Alchemy Layer ##
##################################

resource "aws_s3_object" "psycopg2_sqlalchemy" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/psycopg2_sqlalchemy.zip"
  source = "${path.module}/psycopg2_sqlalchemy.zip"
  source_hash = filemd5("${path.module}/psycopg2_sqlalchemy.zip")
}

resource "aws_lambda_layer_version" "psycopg2_sqlalchemy" {
  s3_bucket = aws_s3_object.psycopg2_sqlalchemy.bucket
  s3_key = aws_s3_object.psycopg2_sqlalchemy.key

  layer_name = "psycopg2_sqlalchemy_${var.environment}"

  compatible_runtimes = ["python3.9"]
  description         = "psycopg2 and sql alchemy python packages"
}

##########################
## HUC Proc Combo Layer ##
##########################

resource "aws_s3_object" "huc_proc_combo" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/huc_proc_combo.zip"
  source = "${path.module}/huc_proc_combo.zip"
  source_hash = filemd5("${path.module}/huc_proc_combo.zip")
}

resource "aws_lambda_layer_version" "huc_proc_combo" {
  s3_bucket = aws_s3_object.huc_proc_combo.bucket
  s3_key = aws_s3_object.huc_proc_combo.key

  layer_name = "huc_proc_combo_${var.environment}"

  compatible_runtimes = ["python3.9"]
  description         = "Includes pandas, pyscopg2, sqlachemy, and rasterio"
}

##################
## Xarray Layer ##
##################

resource "aws_s3_object" "xarray" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/xarray.zip"
  source = "${path.module}/xarray.zip"
  source_hash = filemd5("${path.module}/xarray.zip")
}

resource "aws_lambda_layer_version" "xarray" {
  s3_bucket = aws_s3_object.xarray.bucket
  s3_key = aws_s3_object.xarray.key

  layer_name = "xarray_${var.environment}"

  compatible_runtimes = ["python3.9"]
  description         = "xarray python package"
}

################
## Pika Layer ##
################

resource "aws_s3_object" "pika" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/pika.zip"
  source = "${path.module}/pika.zip"
  source_hash = filemd5("${path.module}/pika.zip")
}

resource "aws_lambda_layer_version" "pika" {
  s3_bucket = aws_s3_object.pika.bucket
  s3_key = aws_s3_object.pika.key

  layer_name = "pika_${var.environment}"

  compatible_runtimes = ["python3.6", "python3.7", "python3.8"]
  description         = "Python pika module"
}

####################
## Requests Layer ##
####################

resource "aws_s3_object" "requests" {
  bucket = var.deployment_bucket
  key    = "terraform_artifacts/${path.module}/requests.zip"
  source = "${path.module}/requests.zip"
  source_hash = filemd5("${path.module}/requests.zip")
}

resource "aws_lambda_layer_version" "requests" {
  s3_bucket = aws_s3_object.requests.bucket
  s3_key = aws_s3_object.requests.key

  layer_name = "requests_${var.environment}"

  compatible_runtimes = ["python3.9"]
  description         = "Python requests module"
}

#############
## Outputs ##
#############

output "es_logging" {
  value = resource.aws_lambda_layer_version.es_logging
}

output "viz_lambda_shared_funcs" {
  value = resource.aws_lambda_layer_version.viz_lambda_shared_funcs
}

output "arcgis_python_api" {
  value = resource.aws_lambda_layer_version.arcgis_python_api
}

output "pandas" {
  value = resource.aws_lambda_layer_version.pandas
}

output "geopandas" {
  value = resource.aws_lambda_layer_version.geopandas
}

output "psycopg2_sqlalchemy" {
  value = resource.aws_lambda_layer_version.psycopg2_sqlalchemy
}

output "huc_proc_combo" {
  value = resource.aws_lambda_layer_version.huc_proc_combo
}

output "xarray" {
  value = resource.aws_lambda_layer_version.xarray
}

output "pika" {
  value = resource.aws_lambda_layer_version.pika
}

output "requests" {
  value = resource.aws_lambda_layer_version.requests
}
