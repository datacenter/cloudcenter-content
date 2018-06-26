# k8gkebuild
This service will build a k8 cluster using gke.  It will also create a service account and grant the appropriate roles required for CloudCenter to manage the cluster.  Storage Classes are also built (standard, gold) to leverage 2 types of storage for workloads.  A "mysql" secret is also added to support a 2 tiered Wordpress demonstration application which demonstrates CloudCener's ability to utilize the additional abstraction layer of "secrets" within K8.

This service is built specifically to be utilized in building a GKE Cluster, which is completely configured and ready to be consumed utilizing CloudCenter 4.9+.  This service can be deployed to any cloud as it utilizes external services to initiate a cluster on GKE via API calls using gcloud(Googld Cloud SDK) and Kubectl.  Note, you cannot deploy this service to a C3 orchestrator in GCE which is configured for "kubernetes"

Assumptions (It is assumed that the following requirements have been met prior to deployment of this service):
1) The current build assumes usage by Cisco HybridCloud TSA's, which utilize a standard project ID and credentials.  There is an encrypted credential file which is downloaded during the deployment which is only valid for the TSA Project ID.
2) A CloudCenter orchestrator has been deployed to Google Cloud for the appropriate region.  Kubernetes orchestrators must be in the same region as the cluster being created.  This orchestrator is configured for cloud type of "kubernetes"
3) The CloudCenter tenant being utilized has been configured with at least 1 additional cloud orchestrator.  This can be an orchestrator in GCE with cloud type "google" or any other cloud as long as the orchestrator has the ability to reach google API endpoints.
4) Access to GCE and GKE have been granted by the TSA owning the shared GCE credentials.
5) The default TSA Project ID will be utilized

Usage;
1) Download and import the service manifest file utilizing the serviceTool.py utility
2) Create an application profile with the service (no app profile configuration is required).
3) Deploy the k8gkebuild application profile to any cloud having an orchestrator which can reach API endspoints at GCE.
4) During deployment you will need to input a service account name and a cluster name.  The remaining deployment parameters can remain default.
5) Once deployed access the GCE console, navigate to Google Kubernetes Engine and review the cluster created.  You should see a cluster with the given name, 2 storage classes (standard, gold), multiple "mysql" secrets (if you chose a namespace other then default).
6) You need to gather the cluster IP for configuration of the CloudCenter cloud region.  Navigate to the "Cluster" link, then click into the cluster name.  From here you will see the cluster IP. Copy this for future use.
7) Navigate to the deployment details of your k8gkebuild deployment.  Expand the single node to get to the node details.  Here in the task details, toward the top you will see the service account and the "Token" information.  Copy both to a holding area.  Be very careful to get all of the Token as it is easy to leave off the last line during the copy process.
8) In CloudCenter, navigate to Clouds, Add a cloud.  Select cloud type of Kubernetes.
9) Select "Add Cloud Account" link.  Use the service account name, for both the name and the "Service Account Name" fields.  Paste the token into the "Service Account Token" field (no need to remove any newline characters, paste as is).
10) Select "Configure Cloud".  On the details tab configure "Kubernetes Settings".  Paste the IP of the GKE cluster.  No need to populate either of the API version fields
11) select "Configure Orchestrator".  Utilize the IP address of the Google orchestrator which is configured with cloud type of "kubernetes".  Select the account just created.  No need to populate the "Remote Desktop Gateway IP" as it's not relevant to K8.
12) Add instance types.  You can configure types however is required.  Note that MilliCPU's are utilized and that RAM is in "MB's"
13) From here build a "Deployment Environment" to utilize this cloud/account.
14) There are a couple container based application profiles in the CloudCenter-content Github project under the "apps" directory.  One for NGINX and a 2 Tiered WordPress app.  Both names start with "K8"


Limitations:
1) Current build only supports Cisco HybridCloud TSA's with shared credentials and the same TSA project ID.



Future Enhancements:
1) Add enhancements to support additional account/project id credentials for authentication