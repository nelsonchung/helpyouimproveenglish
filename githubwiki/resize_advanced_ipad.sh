#!/bin/bash

# 定義一個函數來執行 ffmpeg 指令
process_image() {
    local NAME="$1"
    local SCREEN_RESOLUTION="$2"
    local SCREEN_SIZE="$3"

    INPUT="${NAME}.png"
    OUTPUT="${NAME}_${SCREEN_SIZE}.png"

    ffmpeg -i "$INPUT" -vf "scale=$SCREEN_RESOLUTION" "$OUTPUT"
}

# 針對 ipad 螢幕的設定
SCREEN_RESOLUTION="2732*2048"
SCREEN_SIZE=ipad
NAMES=("ipad_1_mainpage" "ipad_2_addword" "ipad_3_show_words" "ipad_5_test_fill_answer" "ipad_7_junior_page_show_word" "ipad_4_test_options" "ipad_6_junior_page" "ipad_8_junior_apge_show_all_words")

for NAME in "${NAMES[@]}"; do
    process_image "$NAME" "$SCREEN_RESOLUTION" "$SCREEN_SIZE"
done

