# Cursor Stats CSV Processor

A macOS app that processes Cursor analytics CSV files to filter and merge data for Swift extension usage.

## Features

- **Drag and Drop Interface**: Simply drag a CSV file onto the app or click to select one
- **Swift Extension Filtering**: Automatically filters rows to only include entries where Swift is used as the "Most Used Apply Extension" or "Most Used Tab Extension"
- **Data Merging**: Combines multiple days of data for the same user (by email) by summing numeric columns
- **Column Removal**: Automatically removes "Is Active" and "Client Version" columns from the output
- **CSV Export**: Export the processed data to a new CSV file

## How to Use

1. **Launch the App**: Open `CursorStatsTool.app` in Xcode or build and run the project
2. **Load CSV**: Drag and drop your Cursor analytics CSV file onto the app, or click the drop area to select a file
3. **Process Data**: Click the "Process Data" button to filter and merge the data
4. **Export**: Click "Export Processed CSV" to save the results to a new file

## Input Format

The app expects CSV files with the following columns (matching Cursor analytics export format):
- Date
- User ID
- Email
- Is Active
- Chat Suggested Lines Added
- Chat Suggested Lines Deleted
- Chat Accepted Lines Added
- Chat Accepted Lines Deleted
- Chat Total Applies
- Chat Total Accepts
- Chat Total Rejects
- Chat Tabs Shown
- Tabs Accepted
- Edit Requests
- Ask Requests
- Agent Requests
- Cmd+K Usages
- Subscription Included Reqs
- API Key Reqs
- Usage Based Reqs
- Bugbot Usages
- Most Used Model
- Most Used Apply Extension
- Most Used Tab Extension
- Client Version

## Output

The processed CSV will contain:
- All original columns except "Is Active" and "Client Version"
- Data merged by email address (summing numeric columns)
- Only rows where Swift is used as an extension
- "Date" column set to "Merged" for combined entries

## Requirements

- macOS 14.7 or later
- Xcode 16.0 or later (for building)

## Building

1. Open `CursorStatsTool.xcodeproj` in Xcode
2. Select your target device (Mac)
3. Build and run (⌘+R)

## Example

If you have a CSV with multiple days of data for `john.doe@gotinder.com`:
- Day 1: 10 Chat Suggested Lines Added
- Day 2: 15 Chat Suggested Lines Added
- Day 3: 5 Chat Suggested Lines Added

The output will show one row for `john.doe@gotinder.com` with 30 Chat Suggested Lines Added (10+15+5). 