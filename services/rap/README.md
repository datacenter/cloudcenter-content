# RAP - Request Approval Process

This service uses email to enable submitted jobs to go through an approval process.

The primary use case for this service is for environments where more complex approval processes are desired, e.g. beyond the native single step approval process at the deployment environment level, and no other external mechanism is available to handle these requests, e.g. an ESC or CMDB.

Typically this service would be placed at the lowest level of the application profile, such that an approved request (exit 0) allows the job to continue on processing, and a denied request (exit 1) causes the job to terminate.  However, the service should work fine if placed between components as well.

By default the service comes with 4 approval levels - architect, manager, director, and VP; the process utilizes TotalCost as the mechanism to decide the number of approvals required.  TotalCost, by default, is calculated by multiplying the MonthlyCost x 36.

The service can be modified as needed, the default configuration options are available in the service properties section of the web-ui and are as follows:

1) ArchEmail, ArchApprovalAmount
2) MgrEmail, MgrApprovalAmount
3) DirEmail, DirApprovalAmount
4) VPName, VPEmail
5) RAPEmail, RAPLogin, RAPPass
6) Pop3Server, SMTPServer
7) Today

The service uses several native CloudCenter environment variables:

1) %JOB_NAME%
2) %USER_NAME%
3) %EMAIL_ADDRESS%
4) %DEPLOYMENT_ENV%
5) %TIME%

The flow of the service can be seen here https://github.com/datacenter/cloudcenter-content/tree/master/services/rap/approval-flow.jpg, but the basic process is as follows:

1) Create Variables
2) Check if approval is required, if not exit 0, if so then
3) Create an email template, e.g. %USER_NAME% is requesting job %JOB_NAME% be deployed to %DEPLOYMENT_ENV% %Today% at %TIME%, please reply with approved or denied.
4) Send email request to ArchEmail
5) Poll the POP3 server every 60 seconds for messages with matching %JOB_NAME% and pull new messages
6) If the message contains approved, check to see if further approvals are needed, and if so send another email to the next approver, else exit the service with an error (terminating the job)
7) Log the events and email the requesting user %EMAIL_ADDRESS% with the status

This service is written in python using native smtplib and poplib modules.  More info and references can be found here https://docs.python.org/3/library/smtplib.html and here https://docs.python.org/3/library/poplib.html

This has been tested with CloudCenter 4.8.2.1

This service is released under the GNU General Public License version 2.0, which is an open source license.
