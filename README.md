This script is free software, distributed under the license
**GNU General Public License, Version 3 (GPLv3)**

**Support free software, support free science.**

---

# SPLITTER

**Version:** 1.0 (2025-04-17)
**Author:** Gustavo Silveira
If you encounter any bugs or issues, please report them via email to:
**silveira@tuta.io**

---

## DESCRIPTION

This script extracts all non-empty intervals in a specified tier, saving the audio and the TextGrid of each of these intervals separately into individual files. Optionally, a period of silence can be added to both ends of the interval.

---

## INPUT

A directory containing one or more pairs of audio files and their corresponding TextGrid files.

---

## OUTPUT

Individual audio and TextGrid files for each extracted interval, saved in a user-specified output directory.

---

## PARAMETERS

- **INTERVAL TIER NUMBER**
  The index of the tier from which non-empty intervals will be extracted.

- **FILTER INTERVALS**
  If specified, only intervals whose label matches the given pattern will be extracted. This can be a regular expression.

- **SAMPLING FREQUENCY**
  Required by Praat's extraction function. All audio files must share the same sampling frequency.

- **AMOUNT OF SILENCE**
  Duration (in seconds) of silence to append to both the beginning and end of each extracted interval. Set to `0` if no silence should be added.

---

## INTERVAL IDENTIFICATION

To differentiate the extracted intervals from the same input file, each interval's output filename must include a unique tag. The script supports three identification methods:

- **ENUMERATION**
  Intervals are numbered sequentially: 1, 2, 3, etc.

- **START AND END TIMES**
  The interval's start and end times (in milliseconds) are appended to the filename.

- **INTERVAL LABEL**
  The label of the interval is appended to the filename.

> More than one identification method can be enabled simultaneously.

---

## GROUPING EXTRACTED INTERVALS

If your input filenames encode variables (e.g., speaker ID, condition), you can enable the **GROUPING** option to automatically organize the extracted intervals into subfolders based on those variables.

To use this feature, you must specify:

1. The separator character used in the filenames (e.g., `_` or `-`)
2. The position (starting from 1) of the variable in the filename

### Example

Given a filename:
`speaker_condition_item.wav`

- Use separator: `_`
- To group by speaker → set position to `1`
- To group by condition → set position to `2`

The extracted intervals will then be saved in subfolders named according to the selected variable.
