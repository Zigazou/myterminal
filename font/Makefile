extended_videotex.mif: extended_videotex.png
	python3 png_to_mif.py

extended_videotex.png: extended_videotex.svg
	inkscape -f extended_videotex.svg -e extended_videotex.png

font_sim.v: extended_videotex.png
	python3 png_to_sim.py

clean:
	rm -f extended_videotex.png extended_videotex.mif font_sim.v
