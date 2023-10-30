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

# 針對 6.7 吋螢幕的設定
SCREEN_RESOLUTION="1290*2796"
SCREEN_SIZE=67
NAMES=("1_english_page" "2_input_word" "3_show_word" "4_add_word_successful" "5_show_all_words" "6_test_options" "7_wrong_answer" "8_correct_answer" "9_test_fill_answer" "10_junior_page" "11_junior_page_show_word" "12_junior_page_show_all_words" "13_junior_page_show_favorite_words" "14_setting_page")

for NAME in "${NAMES[@]}"; do
    process_image "$NAME" "$SCREEN_RESOLUTION" "$SCREEN_SIZE"
done

# 針對 5.5 吋螢幕的設定
SCREEN_RESOLUTION="1242*2208"
SCREEN_SIZE=55

for NAME in "${NAMES[@]}"; do
    process_image "$NAME" "$SCREEN_RESOLUTION" "$SCREEN_SIZE"
done
