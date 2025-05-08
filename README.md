# taxi-platform
Scalable, event-driven backend platform for real-time taxi operations and data enrichment

# 1. Assumptions
- Focus lies on Data availability rather than just in time data arrival -> At least once delivery of data
- Data always needs to be encrypted at rest and in transit
- Zero Trust principle needs to be applied
- The scalability of the application needs to be ensured
- How to take care of historical data
- What makes the best use of data storage
- Define tooling for data analytics
- Telemetric data is transferred every 5 seconds
- MQTT can be used as transmission protocol
- Data needs to be buffered locally in case of connectivity loss
- Kernel Density Estimation needs to be ensured for proper taxi placement

# 2. Architecture

![](architecture.png)

## 2.1 Solution overview
The architecture is divided into several sections:
- Taxi
    - IOT-Device running in the taxi's themselves
- Client
    - Client communication towards the platform
- AWS Data Management
    - Logic for the complete data ingestion and data preparation
- AWS taxi drives
    - Logic for the complete application and data storage
- Monitoring/Analytics/Observability
    - Logic to ensure Monitoring, Analytics and Observability requirements

## 2.2 Data flow 

The data flow of the application is designed in a specific manner.

1. A new order must always be sent by the customer to ensure a driver cannot start a trip without a customer.
2. The request gets forwarded to the API-Gateway which triggers a Lambda function to put the order information into a DynamoDB. 
3. The triggered Lambda function sends an event to Kinesis Data Streams (order_created) which gets delivered to the AWS IOT-Core
4. The message arrives at the proper Taxi by using the MQTT-Protocol
5. The Driver now needs to accept the order and by doing so a new event (trip_start) gets sent to the IOT core
6. The IOT core is set up to send messages towards the Kinesis Data Streams which forwards this to Managed Service for Apache Flink 
7. In Apache Flink the initial trip_start message is received. Based on this initial information, Flink will calculate the city by using the reverse-geocoding tool `Nominatim`. All messages are also backed up to a raw s3 bucket to ensure no data can be lost even in case of a failure of flink.
8. Now the periodic telemetric update starts. The IOT-Device in the taxi will start transferring location updates every 5 seconds. Those will again be sent over IOT-Core and Kinesis Data Streams towards Flink. Flink will enrich the initial message with the periodic location updates coming from the telemetric updates. Based on this a full location traceability is given based on 5 second intervals. Based on this Flink will also calculate the total travelled distance
9. As soon as the destination has been reached, the Taxi sends a termination event (trip_end) to the IOT-Core, Kinesis Data Streams and Flink. 
10. Flink receives the trip_end event and prepares an enriched message (order information, trip information, location information, total distance and estimated city) to send to another Kinesis Data Stream. 
11. The enriched message is sent to an AWS Step Function to provide a logical order of tasks which should be fulfilled
    - Get detailed customer Data which was stored in the DynamoDB before by using the orderID from the enriched message
    - Use the complete information to trigger a lambda function `json2pdf` which generates a Receipt by using a HTML-Template which has a pre-defined variable setting for the message data. The generated receipt will then be stored in an s3 bucket `receipts`
    - The generated receipt will be sent to the customer via E-Mail by using custom E-Mail Templates in AWS SES
    - In case the lambda fails during the pdf generation, an event to the SQS queue will be sent to ensure all processing failures are stored in a central queue.
12. Additionally, the data is delivered to an s3 bucket `enriched data` by using a proper partitioning based on city and date
12. Existing messages in the Error SQS-Queue will be used for a custom Alerting action
13. The partitioned data is used by a glue crawler to ensure data lake capabilities in the form of a glue database with glue tables
14. The tables created can be used in Athena to ensure proper SQL-based queries. 
15. Monitoring can be ensured by using Grafana
16. Analytics can be ensured by using Tools such as Power Bi or AWS Quicksight, Apache Superset, or similar. The revenue per city is available as the data has proper City information based on the trip_start location reverse-geocoding. Also, the length of the trips is available as this has been calculated by Flink.
17. End-to-End Observability is ensured by using DataDog for the complete AWS account

## 2.3 Data structure

To ensure the minimal functionality of the application, the following data structure is used:
- **Trip Start**: This is the initial order which is created by the customer. It contains the following information:

    <table>
        <tr>
            <th>Field</th>
            <th>Description</th>
        </tr>
        <tr>
            <td>OrderID</td>
            <td>Unique identifier for the order</td>
        </tr>
        <tr>
            <td>CustomerID</td>
            <td>Unique identifier for the customer</td>
        </tr>
        <tr>
            <td>CarID</td>
            <td>Unique identifier for the car</td>
        </tr>
        <tr>
            <td>DriverID</td>
            <td>Unique identifier for the driver</td>
        </tr>
        <tr>
            <td>Timestamp</td>
            <td>Date and time when the order was created</td>
        </tr>
        <tr>
            <td>StartLocation</td>
            <td>Starting location of the trip in latitude and longitude</td>
        </tr>
    </table>

- **Telemetry**: This is the periodic update which is sent by the IOT-Device in the taxi. It contains the following information:

    <table>
        <tr>
            <th>Field</th>
            <th>Description</th>
        </tr>
        <tr>
            <td>OrderID</td>
            <td>Unique identifier for the order</td>
        </tr>
        <tr>
            <td>Timestamp</td>
            <td>Date and time when the telemetry data was sent</td>
        </tr>
        <tr>
            <td>Location</td>
            <td>Current location of the taxi in latitude and longitude</td>
        </tr>
        <tr>
            <td>Speed</td>
            <td>Current speed of the taxi in km/h</td>
        </tr>
        <tr>
            <td>Engine Status</td>
            <td>Status of the engine (on/off)</td>
        </tr>
    </table>

- **Trip End**: This is the final event which is sent by the IOT-Device in the taxi. It contains the following information:

    <table>
        <tr>
            <th>Field</th>
            <th>Description</th>
        </tr>
        <tr>
            <td>OrderID</td>
            <td>Unique identifier for the order</td>
        </tr>
        <tr>
            <td>CustomerID</td>
            <td>Unique identifier for the customer</td>
        </tr>
        <tr>
            <td>CarID</td>
            <td>Unique identifier for the car</td>
        </tr>
        <tr>
            <td>DriverID</td>
            <td>Unique identifier for the driver</td>
        </tr>
        <tr>
            <td>Timestamp</td>
            <td>Date and time when the trip ended</td>
        </tr>
        <tr>
            <td>Location</td>
            <td>Ending location of the trip in latitude and longitude</td>
        </tr>
    </table>


- **Enriched Data**: This is the final data which is sent to the S3 bucket. It contains the following information:

    <table>
        <tr>
            <th>Field</th>
            <th>Description</th>
        </tr>
        <tr>
            <td>OrderID</td>
            <td>Unique identifier for the order</td>
        </tr>
        <tr>
            <td>CustomerID</td>
            <td>Unique identifier for the customer</td>
        </tr>
        <tr>
            <td>CarID</td>
            <td>Unique identifier for the car</td>
        </tr>
        <tr>
            <td>DriverID</td>
            <td>Unique identifier for the driver</td>
        </tr>
        <tr>
            <td>Timestamp</td>
            <td>Date and time when the trip ended</td>
        </tr>
        <tr>
            <td>StartLocation</td>
            <td>Starting location of the trip in latitude and longitude</td>
        </tr>
        <tr>
            <td>EndLocation</td>
            <td>Ending location of the trip in latitude and longitude</td>
        </tr>
        <tr>
            <td>LocationHistory</td>
            <td>List of locations during the trip in latitude and longitude</td>
        </tr>
        <tr>
            <td>Distance</td>
            <td>Total distance of the trip in km</td>
        </tr>
        <tr>
            <td>City</td>
            <td>City where the trip took place</td>
        </tr>
        <tr>
            <td>Fare</td>
            <td>Total fare of the trip in USD</td>
        </tr>
        <tr>
            <td>Duration</td>
            <td>Total duration of the trip in seconds</td>
        </tr>
    </table>

## 2.4 Optimal taxi placement

One requirement for the application is the proper placement of taxis throughout the various cities. To provide manual management insight based on the available data we can use Grafana as visualization tool by making use of the heatmap feature when using geodata. 
The optimal placement of taxis can be ensured by using a combination of time series and geodata [trip start time and trip start location (lat/lon)] in Grafana.

![](taxi_placement_heatmap.png)

This test data has been evaluated by using test data of car crashes in the city of Tempe in Arizona. The dataset can be found [here](https://data.tempe.gov/datasets/tempegov::1-08-crash-data-report-detail/about). By using this data, we can already see corners in the city which are most likely more dangerous than others. This is because the data points are clustered in specific areas of the city. The heatmap shows the density of the data points in a specific area. The more data points are available in a specific area, the redder the area will be shown in the heatmap.


The visualization in our usecase allows us to detect specific hotspots throughout the city as there will be more clustered data points in comparison to other places in the city. This is because we have places of common interest (Train stations, sightseeing attractions, stadiums, etc.) which will mark an optimal taxi placement.

# 3. Automation

Terraform will be the main way of deploying this application to AWS. The pipeline itself looks like the following:

![](ci_cd_structure.png)

In theory there are 2 major variables which can be used when triggering the pipeline:
- `terraform_actions`
    - `plan` -> This will only create a plan of the changes which will be applied to the AWS account. This is used for testing purposes and can be used to check if the pipeline is working as expected.
    - `destroy` -> This will destroy the complete infrastructure which has been created by the pipeline. This is used for testing purposes and can be used to check if the pipeline is working as expected.
    - `apply` -> This is the default action so this will be used when no other action is specified. This will apply the changes to the AWS account and create the complete infrastructure.
- `deploy_targets`
    - by setting a specific deploy target we can ensure that only a specific part of the infrastructure will be deployed. This functionality is given by using the `-target` flag in terraform. This is used for testing purposes and can be used to check if the pipeline is working as expected.
    All targets need to be defined in a list of strings and will be used to create the terraform command. The script which takes care of this looks like this:

    ```bash
    unset terraform_target
    deploy_target=("module.iam" "module.lambda.aws_lambda_function.json_to_pdf")
    for target in ${deploy_target[@]}; do 
        terraform_target="$terraform_target -target $target"
    done

        bash -c "terraform plan $terraform_target"
    ```

    This script for example will only deploy the IAM module and the lambda function `json_to_pdf` as well as its dependencies.

# 4. Data Exfiltration and Infiltration

To effectively avoid data exfiltration and infiltration, the following must be ensured:

- **Encryption enabled for every service using AWS KMS** to protect sensitive data.
- **TLS enforced for all communications** to secure data in transit.
- **Data always encrypted both at rest and in transit** for comprehensive protection.
- **Secrets securely managed in AWS Secrets Manager** to prevent unauthorized access.
- **Private VPC Endpoints used instead of public endpoints** to limit network exposure.
- **IAM permissions follow the principle of least privilege**, granting only necessary access for each component.
- **Web Application Firewall (WAF) in place** to defend against web-based attacks.
- **JWT payloads fixed and signed with a defined secret** to ensure token integrity.
- **API Gateway used to enforce authentication and authorization** for all API access.
- **AWS Guard Duty enabled** to detect and respond to malicious activity.
- **AWS Inspector utilized** to identify and remediate infrastructure vulnerabilities.
- **AWS Config used to ensure compliance** with security policies and best practices.
- **AWS CloudTrail enabled for audit logging and monitoring** to maintain visibility into all account activities.


# 5. Vision
The future direction of the taxi-platform focuses on several key areas to enhance scalability, intelligence, and operational efficiency:

- **Migration of microservices to EKS**: Transitioning all microservices to Amazon Elastic Kubernetes Service (EKS) to improve scalability, manageability, and resilience.
- **Integration of AI-driven decision processes**: Leveraging artificial intelligence for advanced operational capabilities, including:
    - **Demand forecasting**
    - **Dynamic pricing**
    - **Dynamic taxi placement**
    - **Dynamic route optimization**
    - **Real-time ETA prediction**
- **Adoption of MLOps methodologies**: Establishing strong practices for model monitoring, governance, and observability to support reliable and scalable machine learning operations.
- **Adoption of a multi-cloud strategy**: Preparing the platform for deployment across multiple cloud providers such as GCP and Azure, ensuring flexibility and reducing vendor lock-in.
- **Expansion to a full product**: Evolving from an IoT component to a comprehensive application that simplifies order acceptance and provides traffic-based route optimization for drivers.
- **Enhancement of self-service analytics**: Offering users improved analytics capabilities by integrating more data sources and providing richer data points.
- **Improvement of data lake architecture**: Upgrading the data lake structure to include robust data warehousing, schema validation, and support for evolving data models.
- **Implementation of FinOps best practices**: Ensuring cost efficiency through methods such as utilizing S3 Glacier for archival storage and consolidating components within central EKS clusters.
- **Integration of predictive maintenance**: Utilizing data analytics and machine learning to predict and prevent vehicle breakdowns, enhancing operational efficiency and reducing downtime.