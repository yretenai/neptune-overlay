import sys, requests, yaml

branch = "swift-6_0-branch"
if len(sys.argv) > 1:
    branch = sys.argv[1]

data = requests.get("https://raw.githubusercontent.com/apple/swift-org-website/main/_data/builds/%s/ubi9.yml" % branch).content
builds = yaml.safe_load(data)
sys.stdout.write(builds[0]["dir"])
