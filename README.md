**Support free software, support open science.**

---

# SPLITTER

This script extracts all non-empty intervals in a specified tier, saving the audio and the TextGrid of each of these intervals separately into individual files. Optionally, a period of silence can be added to both ends of the interval.

If you encounter any bugs or issues, please report them via email to:
**silveira@tuta.io**

## Description

**Input:**
A directory containing one or more pairs of audio files and their corresponding TextGrid files.

**Output:**
Individual audio and TextGrid files for each extracted interval, saved in a user-specified output directory.

### Parameters

- **Interval tier number:**
  The index of the tier from which non-empty intervals will be extracted.

- **Filter intervals:**
  If specified, only intervals whose label matches the given pattern will be extracted. This can be a regular expression.

- **Sampling frequency:**
  Required by Praat's extraction function. All audio files must share the same sampling frequency.

- **Amount of silence:**
  Duration (in seconds) of silence to append to both the beginning and end of each extracted interval. Set to `0` if no silence should be added.

#### Interval identification

To differentiate the extracted intervals from the same input file, each interval's output filename must include a unique tag. The script supports three identification methods:

- **Enumeration:**
  Intervals are numbered sequentially: 1, 2, 3, etc.

- **Start and end times:**
  The interval's start and end times (in milliseconds) are appended to the filename.

- **Interval label:**
  The label of the interval is appended to the filename.

More than one identification method can be enabled simultaneously.

#### Grouping extracted intervals

If your input filenames encode variables (e.g., speaker ID, condition), you can enable the **Grouping** option to automatically organize the extracted intervals into subfolders based on those variables.

To use this feature, you must specify:

1. The **Separator** character used in the filenames (e.g., `_` or `-`)
2. The **Position** (starting from 1, counting from left to right) of the variable in the filename

##### Example

Given a filename:
`speaker_condition_item.wav`

- Use Separator: `_`
- To group by speaker, set Position to `1`
- To group by condition, set Position to `2`

The extracted intervals will then be saved in subfolders named according to the selected variable.
