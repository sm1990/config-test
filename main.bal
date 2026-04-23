import ballerina/io;

# Enum-like mode values so generated schema can expose a dropdown/select.
public type Mode "DEV"|"TEST"|"PROD";

# Required nested object config for host/port/basePath UI testing.
@display {label: "Target Service"}
public type TargetService record {|
    @display {label: "Host"}
    string host;
    @display {label: "Port"}
    int port;
    @display {label: "Base Path"}
    string basePath;
|};

# Structured array item for array-of-record UI testing.
@display {label: "Endpoint"}
public type Endpoint record {|
    @display {label: "Name"}
    string name;
    @display {label: "URL"}
    string url;
    @display {label: "Timeout (seconds)"}
    int timeout;
|};

# Grouped auth config kept in the root module for better builder compatibility.
@display {label: "Auth"}
public type AuthConfig record {|
    @display {label: "Username"}
    string username;
    @display {label: "Password", kind: "password"}
    string password;
    @display {label: "Client ID"}
    string clientId;
    @display {label: "Client Secret", kind: "password"}
    string clientSecret?;
|};

# Grouped messaging config kept in the root module for better builder compatibility.
@display {label: "Messaging"}
public type MessagingConfig record {|
    @display {label: "Queue Name"}
    string queueName;
    @display {label: "Topic Name"}
    string topicName?;
|};

# 1. Required top-level configs.
@display {label: "Startup Message"}
configurable string message = ?;

@display {label: "Retry Count"}
configurable int retryCount = ?;

@display {label: "Enabled"}
configurable boolean enabled = ?;

# 2. Optional configs.
@display {label: "Region"}
configurable string region = "us-east-1";

@display {label: "Threshold"}
configurable decimal threshold = 0.75;

# 3. Secret config. The `kind: "password"` hint is intended to help schema-driven UIs
# render this as a masked/sensitive input if supported.
@display {label: "API Key", kind: "password"}
configurable string apiKey = ?;

# 4. Enum-like config using a finite type for richer schema generation.
@display {label: "Mode"}
configurable Mode mode = "DEV";

# 5. Nested object config.
@display {label: "Target Service"}
configurable TargetService targetService = ?;

# 6. Map config.
@display {label: "Labels"}
configurable map<string> labels = {};

@display {label: "Limits"}
configurable map<int> limits = {};

# 7. Array config.
@display {label: "Recipients"}
configurable string[] recipients = [];

@display {label: "Backoff Seconds"}
configurable int[] backoffSeconds = [1, 5, 10];

# 8. Array of records / structured array.
@display {label: "Endpoints"}
configurable Endpoint[] endpoints = [];

# 9. Union / anyOf-style config for scalar union.
@display {label: "Correlation Key"}
configurable string|int correlationKey = "auto";

# 9. Union / anyOf-style config for single string vs string array.
@display {label: "Audience"}
configurable string|string[] audience = "icp-ui-test";

# 10/11. Grouped config values that are friendly for config-group linking.
@display {label: "Auth"}
configurable AuthConfig auth = {username: "", password: "", clientId: ""};

@display {label: "Messaging"}
configurable MessagingConfig messaging = {queueName: ""};

public function main() returns error? {
    printInfo("ICP automation configuration UI test started");
    printInfo(string `Startup summary: enabled=${enabled}, mode=${mode}, region=${region}, retryCount=${retryCount}, threshold=${threshold}`);

    printInfo(string `message=${message}`);
    printInfo(string `apiKey(masked)=${maskSecret(apiKey)}`);
    printInfo(string `correlationKey=${correlationKey.toString()}`);
    printInfo(string `audience=${audience.toString()}`);

    printInfo(string `targetService=${targetService.toString()}`);
    printInfo(string `labels=${labels.toString()}`);
    printInfo(string `limits=${limits.toString()}`);
    printInfo(string `recipients=${recipients.toString()}`);
    printInfo(string `backoffSeconds=${backoffSeconds.toString()}`);
    printInfo(string `endpoints=${endpoints.toString()}`);

    printInfo(string `auth.username=${auth.username}`);
    printInfo(string `auth.password(masked)=${maskSecret(auth.password)}`);
    printInfo(string `auth.clientId=${auth.clientId}`);
    printInfo(string `auth.clientSecret(masked)=${maskSecret(auth.clientSecret ?: "")}`);
    printInfo(string `messaging.queueName=${messaging.queueName}`);
    printInfo(string `messaging.topicName=${messaging.topicName ?: ""}`);

    printInfo("Configuration logging complete");
}

function maskSecret(string value) returns string {
    int length = value.length();
    if length == 0 {
        return "<empty>";
    }
    if length <= 4 {
        return repeatedMask(length);
    }

    string prefix = value.substring(0, 2);
    string suffix = value.substring(length - 2, length);
    return prefix + repeatedMask(length - 4) + suffix;
}

function repeatedMask(int count) returns string {
    string mask = "";
    foreach int _ in 1 ... count {
        mask += "*";
    }
    return mask;
}

function printInfo(string message) {
    io:println(string `[INFO] ${message}`);
}
