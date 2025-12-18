#!/usr/bin/env bash
# resize_screenshots.sh
# Skaluje screenshoty iPhone 12 (1170x2532) do rozmiarów App Store
# Używa ImageMagick z filtrem Lanczos (najlepsza jakość upscale)

SCRIPT_DIR="$(dirname "$0")"
INPUT_DIR="$SCRIPT_DIR/screenshots"
OUTPUT_DIR_67="$SCRIPT_DIR/screenshots_6.7"
OUTPUT_DIR_65="$SCRIPT_DIR/screenshots_6.5"

# Utwórz katalogi wyjściowe
mkdir -p "$OUTPUT_DIR_67" "$OUTPUT_DIR_65"

# Licznik dla nazw
counter=1

for input_file in "$INPUT_DIR"/IMG_*.PNG; do
    old_name=$(basename "$input_file" .PNG)
    new_name=$(printf "btcontrol_%02d" $counter)
    
    echo "Przetwarzam: $old_name -> $new_name"
    
    # 6.7" (1290x2796) - wymagane
    magick "$input_file" -alpha remove -filter Lanczos -resize 1290x2796! "$OUTPUT_DIR_67/${new_name}.png"
    
    # 6.5" (1284x2778) - wymagane
    magick "$input_file" -alpha remove -filter Lanczos -resize 1284x2778! "$OUTPUT_DIR_65/${new_name}.png"
    
    counter=$((counter + 1))
done

echo ""
echo "Gotowe!"
echo "6.7\" screenshoty: $OUTPUT_DIR_67/"
echo "6.5\" screenshoty: $OUTPUT_DIR_65/"
