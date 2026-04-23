import ballerina/log;

import icptest/automation_ui_config_test.auth;
import icptest/automation_ui_config_test.messaging;

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

public function main() returns error? {
    log:printInfo("ICP automation configuration UI test started");
    log:printInfo(string `Startup summary: enabled=${enabled}, mode=${mode}, region=${region}, retryCount=${retryCount}, threshold=${threshold}`);

    log:printInfo(string `message=${message}`);
    log:printInfo(string `apiKey(masked)=${maskSecret(apiKey)}`);
    log:printInfo(string `correlationKey=${correlationKey.toString()}`);
    log:printInfo(string `audience=${audience.toString()}`);

    log:printInfo(string `targetService=${targetService.toString()}`);
    log:printInfo(string `labels=${labels.toString()}`);
    log:printInfo(string `limits=${limits.toString()}`);
    log:printInfo(string `recipients=${recipients.toString()}`);
    log:printInfo(string `backoffSeconds=${backoffSeconds.toString()}`);
    log:printInfo(string `endpoints=${endpoints.toString()}`);

    log:printInfo(string `auth.username=${auth:username}`);
    log:printInfo(string `auth.password(masked)=${maskSecret(auth:password)}`);
    log:printInfo(string `auth.clientId=${auth:clientId}`);
    log:printInfo(string `auth.clientSecret(masked)=${maskSecret(auth:clientSecret)}`);
    log:printInfo(string `messaging.queueName=${messaging:queueName}`);
    log:printInfo(string `messaging.topicName=${messaging:topicName}`);

    log:printInfo("Configuration logging complete");
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
