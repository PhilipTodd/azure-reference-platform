"""Check the main platform template and Development parameters against reviewed controls."""
import argparse
import json
import xml.etree.ElementTree as ET
from pathlib import Path


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify(template, parameters):
    resources = []

    def walk(document):
        for resource in document.get("resources", []):
            require(not any(key in resource for key in ["scope", "subscriptionId"]),
                    "No resource may escape the reviewed subscription")
            if resource["type"].lower() == "microsoft.resources/deployments":
                require(resource.get("resourceGroup") == "[parameters('platformResourceGroupName')]",
                        "Modules must use the established platform resource group")
                properties = resource["properties"]
                require(properties.get("mode") == "Incremental", "Only incremental modules are allowed")
                require("template" in properties, "Linked/unreviewable templates are forbidden")
                walk(properties["template"])
            else:
                resources.append(resource)

    walk(template)
    expected = {
        "microsoft.resources/resourcegroups",
        "microsoft.web/serverfarms",
        "microsoft.operationalinsights/workspaces",
        "microsoft.insights/components",
        "microsoft.sql/servers",
        "microsoft.sql/servers/databases",
        "microsoft.documentdb/databaseaccounts",
        "microsoft.documentdb/databaseaccounts/sqldatabases",
        "microsoft.servicebus/namespaces",
        "microsoft.apimanagement/service",
        "microsoft.apimanagement/service/policies",
        "microsoft.containerregistry/registries",
    }
    types = [resource["type"].lower() for resource in resources]
    require(len(types) == len(expected) and set(types) == expected,
            "Only the existing core resources plus one APIM, its policy and one ACR may be managed")
    values = parameters["parameters"]
    require(values["environment"]["value"] == "dev", "This parameter check is Development-only")
    require(values["platformResourceGroupName"]["value"] == "rg-platform-dev", "Unexpected resource group")
    require(values["appServicePlanSku"]["value"] == "B1", "Development must retain B1")
    by_type = {resource["type"].lower(): resource for resource in resources}
    gateway = by_type["microsoft.apimanagement/service"]
    require(gateway["sku"] == {"name": "Developer", "capacity": 1}, "APIM must be one Developer unit")
    require(gateway["identity"]["type"] == "SystemAssigned", "APIM needs its own identity")
    require(gateway["properties"]["virtualNetworkType"] == "None", "No unreviewed VNet change")
    tls = gateway["properties"]["customProperties"]
    for side in ["", "Backend."]:
        for protocol in ["Tls10", "Tls11", "Ssl30"]:
            key = f"Microsoft.WindowsAzure.ApiManagement.Gateway.Security.{side}Protocols.{protocol}"
            require(tls.get(key) == "false", f"Legacy TLS must be disabled: {key}")
    policy = by_type["microsoft.apimanagement/service/policies"]["properties"]
    require(policy["format"] == "rawxml", "Bootstrap policy must be reviewable raw XML")
    xml = ET.fromstring(policy["value"])
    inbound = xml.find("inbound")
    require(inbound is not None and len(inbound) == 1 and inbound[0].tag == "return-response",
            "Bootstrap gateway must fail closed before any forwarding")
    status = inbound[0].find("set-status")
    require(status is not None and status.get("code") == "503", "Bootstrap gateway must return 503")
    registry = by_type["microsoft.containerregistry/registries"]
    require(registry["sku"]["name"] == "Basic", "Registry must remain Basic")
    properties = registry["properties"]
    require(properties.get("adminUserEnabled") is False, "Registry admin credentials forbidden")
    require(properties.get("anonymousPullEnabled") is False, "Anonymous pull forbidden")
    require(properties.get("roleAssignmentMode") == "AbacRepositoryPermissions",
            "Registry must support repository-scoped grants")
    additions = [by_type[name] for name in [
        "microsoft.apimanagement/service", "microsoft.apimanagement/service/policies",
        "microsoft.containerregistry/registries"]]
    serialised = json.dumps(additions).lower()
    require("listkeys(" not in serialised and "listcredentials(" not in serialised,
            "No secret retrieval in the APIM/ACR additions")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("template")
    parser.add_argument("parameters")
    args = parser.parse_args()
    verify(json.loads(Path(args.template).read_text(encoding="utf-8-sig")),
           json.loads(Path(args.parameters).read_text(encoding="utf-8-sig")))
    print("PASS: main platform resource graph, Development B1, APIM/ACR tiers, TLS and access controls")
