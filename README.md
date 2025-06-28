# Cyclistic-Case-Study:Converting Casual Riders to Members
To analyze the behavioral patterns of casual and member riders, identify key opportunities for conversion, and develop actionable marketing strategies to transform casual users into loyal, profitable members, thereby increasing overall company profits.
# Cyclist Ride Data Analysis (2024)

This repository contains the SQL queries used to analyze Divvy bike share ride data for Chicago from January to June 2024. The analysis aims to uncover patterns and trends in ride behavior, distinguish between casual riders and annual members, and identify popular stations and riding times.

## Business Problem

Cyclistic, a fictional bike-share company, faces a core challenge: **How can they effectively convert casual riders into annual members?** By identifying key behavioral differences between these rider types, this analysis aims to inform a data-driven marketing strategy to boost annual memberships.

## Data Source

The analysis utilizes Cyclistic's publicly available historical trip data, specifically focusing on the first six months of **2024 (January - June)**. Each month's data was initially provided as separate CSV files.

## Tools Used

* **SQL (Google BigQuery):** For comprehensive data cleaning, preprocessing, feature engineering, merging monthly datasets, and performing all analytical aggregations.
* **Microsoft Excel:** Used for initial data inspection, basic cleaning (if any was performed manually before uploading to BigQuery), and primarily for creating visualizations from the aggregated SQL query outputs.

## Data Pipeline & Methodology

The analytical process followed a structured data pipeline within Google BigQuery:

1.  **Raw Data Ingestion (`_raw` tables):** Monthly raw trip data CSVs were loaded into Google BigQuery as `cyclistic_data_analysis.trip_data_XX_2024_raw` tables.
2.  **Data Preprocessing (`_pr` tables):** Each `_raw` monthly table was transformed into a processed (`_pr`) table. This step involved:
    * Filtering out rides with missing station names, coordinates, or invalid (zero/negative) ride lengths.
    * Creating new features crucial for analysis, such as:
        * `ride_length_seconds` and `ride_length_minutes`
        * `day_of_week_name` and `day_of_week_num`
        * `start_hour_of_day`
        * `ride_month`
3.  **Data Merging (`all_merged_trip_data`):** All individual monthly tables were united into a single, comprehensive master table: `cyclist_data.all_merged_trip_data`. This consolidated table serves as the single source of truth for all subsequent analytical queries.
4.  **Analytical Aggregations:** A suite of SQL queries was run against `all_merged_trip_data to generate aggregated data for key insights, corresponding directly to the visualizations in the presentation report.

## Key Insights

Based on the analysis of rider behavior, the following core insights were identified:

* **Ride Length:** Casual riders' average trip duration is substantially longer than annual members' (e.g., Casuals: ~25 mins, Members: ~12 mins). This indicates casual usage leans towards leisure, sightseeing, and extended recreational rides.
* **Usage by Day of Week:** Casual riders show a pronounced increase in usage on weekends, while members maintain consistent usage throughout the weekdays, peaking during commuting hours.
* **Usage by Hour of Day:** Members exhibit clear peak usage during morning and evening commuting hours (e.g., 7-9 AM and 4-6 PM on weekdays). Casuals' usage is more evenly distributed, with a broader peak during midday to late afternoon, especially on weekends.
* **Popular Stations:** Casual riders tend to frequent stations near tourist attractions, parks, and recreational areas, indicating leisure-oriented travel. Member riders' popular stations are often concentrated in business districts or residential areas near public transport hubs, suggesting commute-driven usage.


## Recommendations & Actionable Strategies

To effectively convert casual riders into annual members, the following data-driven strategies are recommended:

1.  **Targeted Promotions for Leisure Use:**
    * Shift marketing messaging beyond daily commuting.
    * Emphasize cost savings for frequent weekend/leisure rides (e.g., offer weekend passes, family bundles).
    * Highlight convenience for exploring the city without bike ownership and access to premium features for members.
2.  **Strategic Partnerships & On-Site Promotions:**
    * Collaborate with local attractions (museums, parks, event venues) near top casual stations to offer joint discounts or exclusive membership perks.
    * Set up temporary sign-up booths or kiosks during peak weekend hours at these high-traffic casual locations to engage potential members directly where they already ride.
3.  **Loyalty Programs for Casuals:**
    * Introduce a tiered system where casual rides accumulate points towards discounts on an annual membership.
    * Send personalized offers to casual riders who frequently take longer or weekend rides, highlighting the cost benefits of membership for their specific usage patterns.

## Future Outlook & Next Steps

* **Monitor Effectiveness:** Implement A/B testing for new promotions and track conversion rates to assess their impact.
* **Explore Additional Data Points:** Integrate external data such as weather patterns, demographic information, or local event schedules for deeper behavioral insights.
* **Conduct User Surveys:** Gather qualitative data directly from casual riders to understand their motivations, pain points, and barriers to committing to an annual membership.

## Repository Structure
.

├── Cyclistic-Case-Study.sql   # The main SQL script for data processing and analysis.

├── Cyclistic Data Analysis Report.pptx   # The presentation summarizing findings and recommendations.

├── Cyclistic Processed Workbook.xlsx     # Consolidated Excel workbook containing all aggregated data sheets and visualizations.

└── README.md                           # This README file, providing an overview of the project.


### **Author:** **Meera Bhardwaj**

---
