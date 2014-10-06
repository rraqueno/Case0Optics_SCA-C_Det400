pro make_goes_lon_lat_bands

;
; Open the GOES image
;
	envi_open_file, 'GOES.img', r_fid=input_fid

;
; Get the file information about the GOES image
;
	envi_file_query, input_fid, dims=dims
	n_samples = dims[2]+1
	n_lines = dims[4]+1
	n_pixels = n_samples * n_lines


;
; Get the projection and map information from the GOES image
;
	image_projection = envi_get_projection(fid=input_fid)
	map_info = envi_get_map_info(fid=input_fid)

;
; Establish a geographic projection to which the samples and
; lines will be converted
;
	point_projection = envi_proj_create(/geographic)

;
; Convert the pixel indices to samples and lines 
;
	pixel_indices = lindgen( n_pixels )
	locations = array_indices( [n_samples, n_lines], $
		pixel_indices, /dimensions )
	samples = locations[0,*]
	lines = locations[1,*]
;
; Convert the image file coordinates to image map coordinates
;
	envi_convert_file_coordinates, input_fid, samples, lines, $
		map_x, map_y,/to_map
;
; Convert the image map coordinates to geographic coordinates
;
	envi_convert_projection_coordinates, map_x, map_y, $
		image_projection, lon, lat, point_projection
;
; Reform the lon, lat vectors into an 2 band image
;
	lon_2D = reform( lon, n_samples, n_lines )
	lat_2D = reform( lat, n_samples, n_lines )
	lon_lat = [[[lon_2D]],[[lat_2d]]]
;
; Write out the lon, lat values as separate bands
;
	envi_write_envi_file,lon_lat,out_name='GOES_lon_lat.img',$
		bnames=['Longitude','Latitude'], map_info=map_info

end
