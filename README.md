# Social Media Engagement Analysis (SQL)

## Project Overview

This project analyzes social media engagement data using SQL to understand user participation, photo engagement, hashtag performance, 
and creator activity. The analysis identifies behavioural patterns, evaluates engagement metrics, and develops data-driven recommendations for user activation, 
content discovery, and influencer marketing.

## Objectives

- Identify missing values and duplicate records.
- Analyze user activity, including posts, likes, comments, and follows.
- Calculate average tags per photo and evaluate hashtag performance.
- Rank users by total engagement and average engagement per post.
- Identify inactive users and segment users based on their behaviour.
- Explore relationships between posting volume and engagement.
- Develop actionable recommendations for social media growth and marketing.

## Database Schema

The project uses seven relational tables:

- **users:** Stores user profiles and registration timestamps.
- **photos:** Contains photo details and the user who uploaded each photo.
- **likes:** Records user interactions with photos.
- **comments:** Stores comments made by users on photos.
- **follows:** Represents follower and followee relationships.
- **tags:** Stores available photo tags.
- **photo_tags:** Connects photos with their associated tags.

## Tools and Technologies

- **SQL** – Data querying, aggregation, and analysis.
- **Common Table Expressions (CTEs)** – Organizing complex queries.
- **JOINs and LEFT JOINs** – Combining related tables.
- **Aggregate Functions** – Calculating counts, averages, and totals.
- **Window Functions** – Ranking users by engagement.
- **Excel** – Correlation analysis and data visualization.
- **PowerPoint** – Presenting findings and recommendations.

## Methodology

1. **Data Validation:** Checked for missing values and duplicate groups in selected columns.
2. **Activity Analysis:** Aggregated user-level and photo-level posts, likes, comments, and tags.
3. **Engagement Analysis:** Compared total engagement with average engagement per post.
4. **Hashtag Analysis:** Evaluated tag usage and average likes per photo.
5. **User Segmentation:** Grouped users according to posting and reaction behaviour.
6. **Strategic Recommendations:** Translated analytical findings into measurable marketing experiments.

## Key Findings

The dataset contains 100 users, 257 photos, 8,782 likes, 7,488 comments, and 501 photo tags.

### 1. User Participation
- 74 users (74%) have posted at least once.
- 26 users have never posted.
- 23 users have never liked a post.
- 13 users are completely inactive, with no posts or reactions.

### 2. Engagement Patterns
- The average engagement is approximately 63.3 likes and comments per post.
- Total engagement is strongly correlated with posting volume (r = 0.998).
- Likes and comments also show a strong positive correlation (r = 0.992).
- Total engagement should be considered alongside average engagement per post to avoid favouring frequent posters.

### 3. Hashtag Performance
- The database contains 501 photo-tag associations.
- The average is 1.95 tags per photo.
- 67 photos (approximately 26%) have no tags.
- The `#dreamy` tag has the highest average likes per photo at 35.75.
- Differences between tag-level averages are relatively small, so controlled testing is recommended before changing campaign strategies.

### 4. User Behaviour Segmentation

Users were classified into four behavioural groups:

- **Silent Users (13):** Neither post nor react.
- **Watchers (13):** React to content but never post.
- **Broadcasters (10):** Post content but never react to others.
- **Regular and Occasional Posters (64):** Users who create content with varying levels of activity.

### 5. Creator Performance
- Eveline95 leads in total engagement with 749 engagements.
- Clint27 follows with 660 engagements.
- Cesar93 ranks third with 646 engagements.
- The top five creators account for approximately 19% of total engagement.
- Follower counts are nearly identical across users, making engagement quality and participation more useful for creator evaluation.

## Business Recommendations

- **Activate Dormant Users:** Recommend relevant accounts and encourage users to perform their first interaction.
- **Encourage Content Creation:** Motivate watchers to publish their first photo.
- **Promote Community Participation:** Encourage broadcasters to react to and engage with other users.
- **Improve Content Discovery:** Prompt users to add tags and personalize recommendations using their interests.
- **Evaluate Creators Effectively:** Consider average engagement per post, posting consistency, and community participation.
- **Test Campaign Strategies:** Use A/B tests and holdout groups to measure the impact of creator and content campaigns.
- **Improve Data Collection:** Record reliable event timestamps, content types, and advertising metrics for more comprehensive analysis.

## Limitations

1. The database contains photo-related activity only. It does not provide sufficient information to compare photos, videos, and reels,
analyze reliable time-based trends, or calculate actual advertising campaign ROI.

2. The observed correlations do not establish causation, and small differences in hashtag performance should be validated through experiments. 
Unusually uniform engagement patterns should also be investigated before rewarding users or selecting brand ambassadors.

## Conclusion

This project demonstrates how SQL can transform social media activity data into actionable insights. By analyzing engagement metrics, 
hashtag performance, and user behaviour, the project identifies opportunities to improve participation, content discovery, and creator selection. 
The findings support data-driven decision-making while highlighting the need for better data collection and controlled experiments.

## Skills Demonstrated

SQL | Data Cleaning | Relational Database Analysis | CTEs | Joins | Aggregation | Window Functions | Engagement Analytics | User Segmentation | 
Correlation Analysis | Data Visualization | Business Recommendations

© Mahesh Nagargoje
