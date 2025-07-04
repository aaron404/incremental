coin := "$FACTORIO_INSTALL_DIR/data/base/graphics/icons/coin.png"

gen_sprites:
    # hsv l,s,h
    convert {{coin}} -modulate 50,0,100 assets/coin-stone.png
    convert {{coin}} -modulate 50,75,90 assets/coin-rusted.png
    convert {{coin}} -modulate 100,100,87 assets/coin-copper.png
    convert {{coin}} -modulate 100,0,100 assets/coin-silver.png
    convert {{coin}} -modulate 100,100,100 assets/coin-gold.png
    convert {{coin}} -modulate 150,0,100 assets/coin-platinum.png
    convert {{coin}} -modulate 125,150,200 assets/coin-sapphire.png
    convert {{coin}} -modulate 115,100,150 assets/coin-emerald.png
    convert {{coin}} -modulate 125,125,80 assets/coin-ruby.png
    convert {{coin}} -modulate 125,50,180 assets/coin-diamond.png
    montage \
        assets/coin-stone.png \
        assets/coin-rusted.png \
        assets/coin-copper.png \
        assets/coin-silver.png \
        assets/coin-gold.png \
        assets/coin-platinum.png \
        assets/coin-sapphire.png \
        assets/coin-emerald.png \
        assets/coin-ruby.png \
        assets/coin-diamond.png \
        -background none \
        -geometry 120x64 \
        -tile 1x10 \
        montage.png