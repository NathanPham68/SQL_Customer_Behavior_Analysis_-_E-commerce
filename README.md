# [SQL] bigquery_Ecommerce_Project
## I. Introduction
This project contains an eCommerce dataset that I will explore using SQL on Google BigQuery. The dataset is based on the Google Analytics public dataset and contains data from an eCommerce website.

## II. Requirements
* [Google Cloud Platform account](https://cloud.google.com/free?utm_source=google&utm_medium=cpc&utm_campaign=japac-VN-all-en-dr-BKWS-all-pkws-trial-EXA-dr-1605216&utm_content=text-ad-none-none-DEV_c-CRE_658271209592-ADGP_Hybrid+%7C+BKWS+-+EXA+%7C+Txt+~+GCP_General_google+cloud+misspelled_main-KWID_43700076378560719-aud-1596662388894:kwd-28814176598&userloc_9040331-network_g&utm_term=KW_google+clound&gclid=CjwKCAjwlJimBhAsEiwA1hrp5gzjp8TbXFlya9sL5k6mqYVZJ0qpbaEQoRnV_EtNx0vWbDlZF3txkxoCwOEQAvD_BwE&gclsrc=aw.ds&hl=en)
* Project on Google Cloud Platform
* [Google BigQuery API](https://cloud.google.com/bigquery/docs/reference/rest) enabled
* [SQL query editor](https://cloud.google.com/monitoring/mql/query-editor) or IDE

## III. Dataset Access
The eCommerce dataset is stored in a public Google BigQuery dataset. To access the dataset, follow these steps:
* Sign in to your Google Cloud Platform account and create a new project.
* Navigate to the BigQuery dashboard and select your newly created project.
* In the navigation panel, select "Add Data" and then select "Search Projects".
* Enter the project ID "bigquery-public-data.google_analytics_sample.ga_sessions" and click "Enter".
* Click on the table "ga_sessions_" to the dataset.

## IV. Exploring the Dataset
In this project, I will write and run SQL queries in Google BigQuery on the Google Analytics dataset to retrieve the necessary data for answering business questions.

### Query 01: Calculate total visit, pageview, transaction and revenue for January, February and March 2017 order by month
[Link to code](https://console.cloud.google.com/bigquery?sq=322729696559:adfe928ac9c64cb0a58a526e93b7aaef)
* SQL code

![image](https://github.com/user-attachments/assets/c1d95ff4-265d-48a8-8481-dce0d828f3ad)

* Query results

![image](https://github.com/user-attachments/assets/efc1ace6-189b-4f2b-9236-1b757eb9b91b)

### Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC).
[Link to code](https://console.cloud.google.com/bigquery?sq=322729696559:f043a6b83f0b4adebe8896d67c5f4378)
* SQL code

![image](https://github.com/user-attachments/assets/ce0cfd09-7b68-46bf-ae19-f33e79cdbac0)

* Query results

![image](https://github.com/user-attachments/assets/4508f9ee-150e-4880-9cda-d676b4a30c1c)

