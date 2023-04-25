import sys
sys.path.append("../utils")
from lambda_function import open_raster, create_raster, upload_raster

def main(product_name, data_bucket, input_files, reference_time):
    variable = "SOILICE"
    
    data_temp, crs = open_raster(data_bucket, input_files[0], variable)
    data_nan = data_temp.where(data_temp != -999900)
    data = data_nan/100  
    data = data.round(2)

    local_raster = create_raster(data, crs)
    raster_name = product_name
    uploaded_raster = upload_raster(reference_time, local_raster, product_name, raster_name)

    return [uploaded_raster]