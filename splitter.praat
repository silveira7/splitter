# This is script is a free software, distributed under the license 
# GNU General Public License, Version 3 (GPLv3)
#
# Support free software, support free science.
#
# --------------------------------------------------------------------
# SPLITTER
# --------------------------------------------------------------------
#
# Version: 1.0 (2025-04-17)
# Author: Gustavo Silveira
# If you encounter any bugs or issues, please report them via email to:
# silveira@tuta.io
#
# DESCRIPTION:
#
# This script extracts all non-empty intervals in a specified tier,
# saving the audio and the TextGrid of each of these intervals separately
# into individual files. Optionally, a period of silence can be added to
# both ends of the interval.
#
# INPUT:
# A directory containing one or more pairs of audio files and their corresponding
# TextGrid files.
#
# OUTPUT: 
# Individual audio and TextGrid files for each extracted interval, saved
# in a user-specified output directory.
#
# PARAMETERS:
#
#    INTERVAL TIER NUMBER: The index of the tier from which non-empty intervals
#    will be extracted.
#
#    FILTER INTERVALS: If specified, only intervals whose label matches
#    the given pattern will be extracted. This can be a regular expression.
#
#    SAMPLING FREQUENCY: Required by Praat's extraction function. All audio
#    files must share the same sampling frequency.
#
#    AMOUNT OF SILENCE: Duration (in seconds) of silence to append to both
#    the beginning and end of each extracted interval. Set to 0 if no silence
#    should be added.
#
# INTERVAL IDENTIFICATION:
#
# To differentiate the extracted intervals from the same input file,
# each interval's output filename must include a unique tag. The script
# supports three identification methods:
#
#    ENUMERATION: Intervals are numbered sequentially: 1, 2, 3, etc.
#
#    START AND END TIMES: The interval's start and end times (in milliseconds)
#    are appended to the filename.
#
#    INTERVAL LABEL: The label of the interval is appended to the filename.
#
# More than one identification method can be enabled simultaneously.
#
# GROUPING EXTRACTED INTERVALS
#
# If your input filenames encode variables (e.g., speaker ID, condition),
# you can enable the GROUPING option to automatically organize the extracted
# intervals into subfolders based on those variables.
# 
# To use this feature, you must specify:
#     1) The separator character used in the filenames (e.g., "_" or "-")
#     2) The position (starting from 1) of the variable in the filename.
#
# Example:
#
# Given a filename: speaker_condition_item.wav
#
# Use separator: "_"
# To group by speaker, set position to 1. To group by condition, set position to 2.
#
# The extracted intervals will then be saved in subfolders named according
# to the selected variable.
#

form: "Splitter - Split intervals into separate files"
    comment: "This script extracts into individual files all non-empty intervals from a tier."
    folder: "Input directory", ""
    folder: "Output directory", ""

    integer: "Interval tier number:", "1"
    sentence: "Filter intervals (regex allowed)", ""
    integer: "Sampling frequency", "44100"

    comment: "Optionally, a period of silence can be inserted at both ends of the interval."
    comment: "Set the parameter below to 0 if you don't want silence insertion."
    real: "Amount of silence (s)", "0.3"

    comment: "How do you want to uniquely identify each extracted interval?"
    comment: "(You can choose more than one method)"
    boolean: "Enumeration", "1"
    boolean: "Start and end times", "0"
    boolean: "Interval label", "0"

    comment: "Group extracted intervals in different folders by a variable coded in the filename?"
    boolean: "Grouping", "0"
    comment: "Which character is used to separate variables in filename?"
    word: "Separator", "_"
    comment: "Which character is used to separate variables in filename?"
    integer: "Position", "1"
endform

if enumeration + start_and_end_times + interval_label == 0
    exitScript: "You need to choose at least one method of interval identification."
endif

if amount_of_silence < 0
    exitScript: "You cannot assign a negative value to amount of silence."
endif

tier = interval_tier_number

if not endsWith (input_directory$, "/")
    input_directory$ = input_directory$ + "/"
endif

if not endsWith (output_directory$, "/")
    output_directory$ = output_directory$ + "/"
endif

if amount_of_silence > 0
    silence = Create Sound from formula: "silence", 1, 0.0, amount_of_silence, sampling_frequency, "0"
endif

createFolder: output_directory$

fileList = Create Strings as file list: "fileList", input_directory$ + "*.TextGrid"
numOfFiles = Get number of strings

for i from 1 to numOfFiles
    selectObject: fileList
    file$ = Get string: i
    file$ = file$ - ".TextGrid"

    if grouping
        tmp_file$ = file$
        counter = 0
        repeat
            counter = counter + 1
            str_length = length (tmp_file$)
            sep = index (tmp_file$, separator$)
            if sep == 0 and counter == 1
                exitScript: "Specified separator not present in filename."
            elsif sep == 0 and position > counter
                exitScript: "Position number is greater then the numbers of parts."
            elsif sep == 0 and position == counter
                current_tag$ = tmp_file$
            else
                current_tag$ = left$ (tmp_file$, sep - 1)
                tmp_file$ = right$(tmp_file$, str_length - sep)
            endif
        until counter == position
        group$ = current_tag$
        createFolder: output_directory$ + group$
        output_new_directory$ = output_directory$ + "/" + group$ + "/"
    else
        output_new_directory$ = output_directory$
    endif

    tg = Read from file: input_directory$ + file$ + ".TextGrid"
    audio = Read from file: input_directory$ + file$ + ".wav"

    selectObject: tg
    numOfIntervals = Get number of intervals: tier

    if enumeration
        numNonEmptyIntervals = Count intervals where: tier, "matches (regex)", ".+"
        numOfDigits = length (string$ (numNonEmptyIntervals))
    endif

    utt_count = 0

    for j from 1 to numOfIntervals
        selectObject: tg
        label$ = Get label of interval: tier, j

        if filter_intervals$ != ""
            match = index (label$, filter_intervals$)
            if match
                @extractIntervals
            endif
        elsif label$ != ""
            @extractIntervals
        endif
    endfor
    selectObject: tg, audio
    Remove
endfor

procedure extractIntervals
    output_filename$ = output_new_directory$ + file$
    utt_count = utt_count + 1

    start_time = Get start time of interval: tier, j
    end_time = Get end time of interval: tier, j

    if enumeration
        zeros = numOfDigits - length (string$ (utt_count))
        utt_num$ = string$ (utt_count)
        for k from 1 to zeros
            utt_num$ = "0" + utt_num$
        endfor
            output_filename$ = output_filename$ + separator$ + utt_num$
    endif

    if interval_label
        output_filename$ = output_filename$ + separator$ + label$
    endif

    if start_and_end_times
        start_time$ = fixed$ (start_time * 1000, 0)
        end_time$ = fixed$ (end_time * 1000, 0)
        output_filename$ = output_filename$ + separator$ + start_time$ + separator$ + end_time$
    endif

    tg_part = Extract part: start_time, end_time, "no"

    if amount_of_silence > 0
        Extend time: amount_of_silence, "end"
        Extend time: amount_of_silence, "start"
        Shift times to: "start time", 0.0
    endif

    Save as text file: output_filename$ + ".TextGrid"

    selectObject: audio
    audio_part = Extract part: start_time, end_time, "rectangular", 1.0, "no"

    if amount_of_silence > 0
        plusObject: silence
        first_concat = Concatenate
        selectObject: silence
        tmp_silence = Copy: "tmp_silence"
        plusObject: first_concat
        second_concat = Concatenate
    endif

    Save as WAV file: output_filename$ + ".wav"

    if amount_of_silence > 0
        selectObject: first_concat, second_concat, tmp_silence
    endif

    selectObject: tg_part, audio_part
    Remove
endproc
