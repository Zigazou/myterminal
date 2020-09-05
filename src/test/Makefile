all: screen_capture.ppm

video_controller_tb: video_controller_tb.v ../video_controller.v font_sim.v charattr_row_sim.v pixels_sim.v
	iverilog -o video_controller_tb \
		video_controller_tb.v \
		../video_controller.v \
		font_sim.v \
		charattr_row_sim.v \
		pixels_sim.v

screen_capture.ppm: video_controller_tb
	./video_controller_tb > screen_capture.ppm

screen_capture.png: screen_capture.ppm
	convert screen_capture screen_capture.png

clean:
	rm -f video_controller_tb screen_capture.ppm screen_capture.png