# GoHighLevel YouTube Channel Data Extractor

This project extracts data from YouTube channels in the GoHighLevel CRM space, including channel information, video details, and links from video and channel descriptions.

## Setup

1. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Make sure you have a valid YouTube API key in `app.py`. The current key is for demonstration purposes and may have usage limitations.

## Usage

### Step 1: Collect YouTube Channel Data

Run the main script to collect data from YouTube videos:

```
python app.py
```

This will:
- Create a sample input file (`input_videos.csv`) if it doesn't exist
- Process the video URLs in the input file
- Generate a CSV file with detailed information about each video and its associated channel
- Save the output to the `output` directory with a timestamp in the filename

### Step 2: Create a Masterlist of GoHighLevel Channels

After collecting the data, run the masterlist script to create a consolidated list of channels:

```
python create_masterlist.py
```

This will:
- Find the most recent data file in the `output` directory
- Process the data to extract unique channels (using the latest video for each channel)
- Extract and categorize links from video and channel descriptions
- Generate a masterlist CSV file with channel information and categorized links
- Save the output to the `output` directory with a timestamp in the filename

## Output Files

### YouTube Channel Data CSV

The `app.py` script generates a CSV file with the following information:
- Video details (title, description, publish date, view count, etc.)
- Channel details (name, description, URL, subscriber count, etc.)
- Playlist information
- Thumbnail URLs

### GoHighLevel Channels Masterlist CSV

The `create_masterlist.py` script generates a CSV file with the following information:
- Channel details (name, description, URL, subscriber count, etc.)
- Latest video information
- Categorized links from video and channel descriptions:
  - GHL Affiliate Links
  - Course/Training Links
  - Newsletter Links
  - Social Media Links
  - Website/Blog Links
  - Other Links

## Customization

You can modify the `input_videos.csv` file to include your own list of YouTube video URLs to process. The script will extract data for each video and its associated channel. 