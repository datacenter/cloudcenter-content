pm.test("Successful status code 2XX", function () {
    pm.response.to.be.success;
});
pm.test("Valid JSON response", function () {
    pm.response.to.be.json;
});
var resUrl = pm.response.json().resource;
pm.test("Valid Resource URL", function () {
    resUrl != null;
});
if(!resUrl) {
    var err = pm.response.json().errors[0].message;
    throw new Error("Unable to get Resource URL. " + err);
}

const getJobDetails = {
  url: resUrl,
  method: 'GET',
  header: pm.request.header,
  params: {
      includeNodeDetails: true
  }
};
const deleteJob = {
  url: resUrl,
  method: 'DELETE',
  header: pm.request.header,
  params: {
      hide: true
  }
};

var waitForDone = function () {
    var checkDone = function(resolve, reject) {
        //console.log(resUrl);
        //if (resUrl) {reject();}
        pm.sendRequest(getJobDetails, function(err, res) {
            let jobStatus = res.json().deploymentEntity.attributes.status;
            let validStates = [
                'Deployed',
                'Terminated',
                'Error',
                'In Progress',
                'Submitted',
                'Terminating',
                'Stopping'
            ];
            let doneStates = ['Deployed', 'Terminated', 'Error'];
            if (validStates.indexOf(jobStatus) == -1) {
                console.log("Job in invalid status: "+jobStatus);
                reject(res.json());
            }
            else if (doneStates.indexOf(jobStatus) != -1) {
                console.log("Job completed with status "+jobStatus);
                resolve(jobStatus);
            } else {
                console.log("Job not done. Current status is "+jobStatus);
                setTimeout(function() {
                    //resolve("Waited 19");
                    checkDone(resolve, reject);
                }, 3000);
            }
        });
    };
    return new Promise(checkDone);
};
var terminateJob = function () {
    return new Promise(function(resolve, reject) {
        pm.sendRequest(deleteJob, function(err, res) {
            resolve("terminating job");
        });
    });
};

var validResource = function () {
    return new Promise(function(resolve, reject) {
        //console.log(resUrl);
        if (resUrl) {
            resolve(resUrl);
        } else {
            console.log("Resouce URL not found.");
            reject(resUrl);
        }
    });
};

var testStatus  = function (status) {
    return new Promise((resolve, reject) => {
        //resolve("test");
        pm.sendRequest(getJobDetails, function(err, res) {
            let jobStatus = res.json().deploymentEntity.attributes.status;
            //resolve("test");
            var test = pm.test("Job Status is "+status, function () {
                 pm.expect(jobStatus).to.eql(status);
            });
            if (jobStatus == status) {
                resolve(jobStatus);
            } else {
                console.log("Job Status was unexpected, skipping " +
                    "cleanup: " + jobStatus
                );
                reject(jobStatus);
            }
        });
    });
};

// Set maximum timeout to 1800 seconds, 30min. This is required
// due to Postman not fully supporting promises. It won't wait
// for them all to finish, so need to set this timer, which Postman
// WILL wait for. Once all the other promises are done, then clear
// the timer to allow Postman to exit the test script.
// https://community.getpostman.com/t/using-native-javascript-promises-in-postman/636
var interval = setTimeout(function() {}, 1800000);

validResource()
    .then(waitForDone)
//waitForDone()
    .then((result) => testStatus("Deployed"))
    .then(terminateJob)
    .then(waitForDone)
    .then((result) => testStatus("Terminated"))
    .then((v) => {clearTimeout(interval);})
    .catch((v) => {
        console.log("Something went wrong");
        clearTimeout(interval);
    })
    ;
